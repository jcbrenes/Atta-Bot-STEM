#!/usr/bin/env python3
'''Genera un mapa navegable del firmware Atta-Bot STEM como vault de Obsidian.

Lee el código de Robot/ y escribe una nota por función, estado, instrucción BLE,
parámetro SET, mensaje serie, comando serie y archivo, enlazadas con [[...]].
Los textos salen de los recuadros de comentarios del código; los enlaces se
deducen de las llamadas, de las asignaciones a estado, de las comparaciones del
protocolo BLE y de la consola Serial.

Uso:
  python3 Robot/tools/mapa_obsidian.py
  python3 Robot/tools/mapa_obsidian.py --salida otra/carpeta
'''
import argparse
import ast
import json
import re
import shutil
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ROBOT = REPO / 'Robot'
SALIDA_POR_DEFECTO = ROBOT / 'Mapa'

ARCHIVOS = [
    ROBOT / 'CodigoESP32' / 'CodigoESP32.ino',
    ROBOT / 'CodigoESP32' / 'RobotConfig.h',
    ROBOT / 'CodigoESP32' / 'MotionRuntime.h',
    ROBOT / 'CodigoESP32' / 'MotionControl.h',
    ROBOT / 'CalibracionMotores' / 'CalibracionMotores.ino',
    ROBOT / 'CalibracionServoHerramienta' / 'CalibracionServoHerramienta.ino',
    ROBOT / 'tools' / 'CalibracionCuadrado.h',
    ROBOT / 'tools' / 'calibrar_cuadrado.cpp',
    ROBOT / 'tools' / 'auditar_giros.cpp',
    ROBOT / 'tools' / 'capturar_movimiento.py',
]

UTILITARIAS = {'clamp', 'within', 'constrain', 'readEncoderCounts',
               'parseFloatValue', 'ledInterno'}
PALABRAS_RESERVADAS = {
    'if', 'for', 'while', 'switch', 'return', 'sizeof', 'else', 'case',
    'catch', 'do', 'new', 'delete', 'static_cast', 'reinterpret_cast',
    'const_cast', 'dynamic_cast', 'decltype',
}

COLORES_GRAFO = {
    'funcion': 0x4A90D9,
    'metodo': 0x7FB3E6,
    'estado': 0xE67E22,
    'instruccion': 0x8E44AD,
    'comando': 0x27AE60,
    'mensaje': 0xC0392B,
    'parametro': 0xF1C40F,
}
FILTRO_GRAFO = '-tag:#indice'
GUIA_IGNORADOS = [
    'Respaldos/', 'Respaldos_SHOW/', 'Binarios/', 'tests/',
    'CodigoESP32/BancoDePruebasPID/', 'CodigoESP32/Preferences/',
    'AttaSTEM_Leisel_Jimena/',
]
GUIAS = [
    'Calibracion_paso_a_paso', 'README', 'Control_movimiento_V2', 'Guia_parametros_SET',
    'Calibracion_cuadrado', 'Auditoria_giros_V2',
    'Auditoria_movimiento_13_Attas',
]


def limpiar_codigo(texto):
    '''Reemplaza comentarios y literales de texto por espacios.

    Conserva la longitud y los saltos de línea, así las posiciones del texto
    limpio sirven para indexar el original.

    Parámetros:
    - texto (str): código C++.

    Retorna:
    - str: el mismo código sin comentarios ni contenido de literales.
    '''
    salida = list(texto)
    i = 0
    n = len(texto)
    while i < n:
        if texto.startswith('//', i):
            while i < n and texto[i] != '\n':
                salida[i] = ' '
                i += 1
        elif texto.startswith('/*', i):
            while i < n and not texto.startswith('*/', i):
                if texto[i] != '\n':
                    salida[i] = ' '
                i += 1
            if i < n:
                salida[i] = salida[i + 1] = ' '
                i += 2
        elif texto[i] in '"\'':
            cierre = texto[i]
            i += 1
            while i < n and texto[i] != cierre:
                if texto[i] == '\\':
                    salida[i] = ' '
                    i += 1
                if i < n and texto[i] != '\n':
                    salida[i] = ' '
                i += 1
            i += 1
        else:
            i += 1
    return ''.join(salida)


def fin_de_bloque(limpio, apertura):
    '''Encuentra la llave que cierra el bloque abierto en apertura.

    Parámetros:
    - limpio (str): código sin comentarios ni literales.
    - apertura (int): posición de la llave de apertura.

    Retorna:
    - int: posición de la llave de cierre.
    '''
    profundidad = 0
    for i in range(apertura, len(limpio)):
        if limpio[i] == '{':
            profundidad += 1
        elif limpio[i] == '}':
            profundidad -= 1
            if profundidad == 0:
                return i
    return len(limpio) - 1


def recuadro_encima(lineas, inicio):
    '''Extrae el texto del recuadro de documentación que precede a una línea.

    Parámetros:
    - lineas (list[str]): el archivo original, por líneas.
    - inicio (int): índice de la primera línea de la firma.

    Retorna:
    - str: el texto del recuadro, sin las barras ni los bordes de asteriscos.
    '''
    texto = []
    i = inicio - 1
    while i >= 0 and not lineas[i].strip():
        i -= 1
    while i >= 0 and lineas[i].strip().startswith('//'):
        texto.insert(0, lineas[i].strip())
        i -= 1
    limpio = []
    for linea in texto:
        if re.fullmatch(r'//\*{3,}', linea):
            continue
        limpio.append(re.sub(r'^//\s?', '', linea))
    return '\n'.join(limpio).strip()


def apertura_en_cero(texto):
    '''Busca la primera llave de apertura que no está dentro de paréntesis.

    Así se distingue la llave del cuerpo de las llaves de inicializadores como
    TurnConfig{} usados en parámetros por defecto.

    Parámetros:
    - texto (str): firma limpia, con saltos de línea.

    Retorna:
    - int: posición de la llave o -1 si no hay.
    '''
    parentesis = 0
    for i, caracter in enumerate(texto):
        if caracter == '(':
            parentesis += 1
        elif caracter == ')':
            parentesis = max(0, parentesis - 1)
        elif caracter == '{' and parentesis == 0:
            return i
    return -1


def prefijo_de_archivo(archivo):
    '''Devuelve el prefijo que evita choques entre nombres de distintos archivos.

    Parámetros:
    - archivo (Path): archivo fuente.

    Retorna:
    - str: prefijo con punto final, o cadena vacía para el firmware principal.
    '''
    if archivo.parent.name == 'tools':
        return archivo.stem + '.'
    if archivo.name == 'CalibracionMotores.ino':
        return 'CalibracionMotores.'
    if archivo.name == 'CalibracionServoHerramienta.ino':
        return 'CalibracionServoHerramienta.'
    return ''


def rangos_de_structs(limpio):
    '''Localiza los structs y clases con su bloque completo.

    Parámetros:
    - limpio (str): código sin comentarios ni literales.

    Retorna:
    - list[tuple[str, int, int]]: nombre, llave de apertura y llave de cierre.
    '''
    rangos = []
    for encontrado in re.finditer(r'\b(?:struct|class)\s+(\w+)[^;{]*\{', limpio):
        apertura = encontrado.end() - 1
        rangos.append((encontrado.group(1), apertura, fin_de_bloque(limpio, apertura)))
    return rangos


def struct_en(rangos, posicion):
    '''Encuentra el struct o clase más interno que contiene una posición.

    Parámetros:
    - rangos (list[tuple]): lo que devuelve rangos_de_structs.
    - posicion (int): posición dentro del archivo.

    Retorna:
    - str | None: nombre del struct contenedor, o None.
    '''
    dentro = [r for r in rangos if r[1] < posicion < r[2]]
    if not dentro:
        return None
    return max(dentro, key=lambda r: r[1])[0]


def buscar_funciones(archivo):
    '''Encuentra las funciones y métodos definidos en un archivo C++.

    Reconoce funciones de nivel superior, métodos inline de struct/clase y
    definiciones con Struct::metodo. Los nombres de las herramientas de PC y de
    los sketches de calibración llevan prefijo de archivo.

    Parámetros:
    - archivo (Path): archivo .ino, .h o .cpp.

    Retorna:
    - list[dict]: una entrada por función con nombre, archivo, línea, firma,
      documentación, cuerpo y si es método.
    '''
    original = archivo.read_text(encoding='utf-8')
    limpio = limpiar_codigo(original)
    lineas = original.split('\n')
    lineas_limpias = limpio.split('\n')
    offsets = [0]
    for linea in lineas:
        offsets.append(offsets[-1] + len(linea) + 1)

    rangos = rangos_de_structs(limpio)
    prefijo = prefijo_de_archivo(archivo)
    funciones = []
    i = 0
    while i < len(lineas_limpias):
        linea = lineas_limpias[i]
        desnuda = linea.strip()
        if not desnuda or linea.lstrip().startswith(('#', '}', '//')):
            i += 1
            continue
        firma = ''
        j = i
        while j < len(lineas_limpias):
            firma += lineas_limpias[j] + '\n'
            if '{' in lineas_limpias[j] or ';' in lineas_limpias[j]:
                break
            j += 1
        if j >= len(lineas_limpias) or '{' not in firma:
            i = j + 1
            continue
        apertura_rel = apertura_en_cero(firma)
        if apertura_rel < 0:
            i = j + 1
            continue
        antes = firma[:apertura_rel]
        if ';' in antes or '(' not in antes:
            i = j + 1
            continue
        if re.match(r'\s*(?:if|for|while|switch|catch|do|return|case)\b', antes):
            i = j + 1
            continue
        if re.match(r'\s*(?:namespace|struct|class|enum|typedef|using|template)\b', antes):
            i = j + 1
            continue
        if '=' in antes.split('(')[0]:
            i = j + 1
            continue
        nombres = re.findall(r'([~\w:]+)\s*\(', antes)
        if not nombres:
            i = j + 1
            continue
        nombre = nombres[-1]
        if nombre in PALABRAS_RESERVADAS:
            i = j + 1
            continue
        apertura = offsets[i] + apertura_rel
        estructura = struct_en(rangos, apertura)
        metodo = bool(estructura)
        if estructura:
            nombre = f'{estructura}.{nombre}'
        elif '::' in nombre:
            nombre = nombre.replace('::', '.')
            metodo = True
        if not metodo:
            nombre = prefijo + nombre
        cierre = fin_de_bloque(limpio, apertura)
        funciones.append({
            'nombre': nombre,
            'archivo': archivo.name,
            'linea': i + 1,
            'firma': ' '.join(original[offsets[i]:apertura].split()),
            'doc': recuadro_encima(lineas, i),
            'cuerpo': original[apertura:cierre + 1],
            'cuerpo_limpio': limpio[apertura:cierre + 1],
            'metodo': metodo,
            'struct': estructura,
        })
        fin_linea = limpio.count('\n', 0, cierre)
        i = max(fin_linea + 1, j + 1)
    return funciones


def firma_python(nodo):
    '''Reconstruye la firma de una función de Python a partir del AST.

    Parámetros:
    - nodo (ast.FunctionDef): función leída por ast.

    Retorna:
    - str: firma legible, sin el cuerpo.
    '''
    partes = []
    for argumento in nodo.args.args:
        partes.append(argumento.arg)
    if nodo.args.vararg:
        partes.append('*' + nodo.args.vararg.arg)
    for argumento in nodo.args.kwonlyargs:
        partes.append(argumento.arg)
    if nodo.args.kwarg:
        partes.append('**' + nodo.args.kwarg.arg)
    return f'def {nodo.name}({", ".join(partes)})'


def buscar_funciones_python(archivo):
    '''Encuentra las funciones de un archivo Python y sus docstrings.

    Parámetros:
    - archivo (Path): archivo .py.

    Retorna:
    - list[dict]: funciones con nombre prefijado, línea, firma, docstring y
      cuerpo.
    '''
    fuente = archivo.read_text(encoding='utf-8')
    arbol = ast.parse(fuente)
    lineas = fuente.split('\n')
    prefijo = prefijo_de_archivo(archivo)
    funciones = []
    for nodo in ast.walk(arbol):
        if not isinstance(nodo, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue
        fin = getattr(nodo, 'end_lineno', nodo.lineno)
        cuerpo = '\n'.join(lineas[nodo.lineno - 1:fin])
        funciones.append({
            'nombre': prefijo + nodo.name,
            'archivo': archivo.name,
            'linea': nodo.lineno,
            'firma': firma_python(nodo),
            'doc': (ast.get_docstring(nodo, clean=True) or '').strip(),
            'cuerpo': cuerpo,
            'cuerpo_limpio': cuerpo,
            'metodo': False,
            'struct': None,
        })
    funciones.sort(key=lambda f: (f['linea'], f['nombre']))
    return funciones


def cabecera(archivo, lineas):
    '''Extrae el bloque de comentarios con que empieza un archivo.

    Parámetros:
    - archivo (Path): archivo fuente.
    - lineas (list[str]): archivo original por líneas.

    Retorna:
    - str: texto de la cabecera, o cadena vacía.
    '''
    if archivo.suffix == '.py':
        try:
            arbol = ast.parse(archivo.read_text(encoding='utf-8'))
            return (ast.get_docstring(arbol, clean=True) or '').strip()
        except (SyntaxError, OSError):
            return ''
    texto = []
    for linea in lineas:
        if not linea.startswith('//'):
            break
        if re.fullmatch(r'//\*{3,}', linea):
            continue
        texto.append(re.sub(r'^//\s?', '', linea))
    return '\n'.join(texto).strip()


def buscar_globales(archivos):
    '''Relaciona cada objeto global y cada miembro de struct con su tipo.

    Parámetros:
    - archivos (list[Path]): archivos del firmware.

    Retorna:
    - dict[str, str]: nombre del objeto → nombre del tipo.
    '''
    tipos = {}
    for archivo in archivos:
        if archivo.suffix == '.py':
            continue
        limpio = limpiar_codigo(archivo.read_text(encoding='utf-8'))
        for encontrado in re.finditer(
                r'\b(?:[\w]+::)*([A-Z]\w+)\s+(\w+)\s*(?:[;,=(\[]|$)', limpio, re.M):
            tipos[encontrado.group(2)] = encontrado.group(1)
    return tipos


def buscar_estados(archivo):
    '''Lee los valores del enum posibles_Estados del firmware principal.

    Parámetros:
    - archivo (Path): CodigoESP32.ino.

    Retorna:
    - list[str]: los estados, en el orden del enum.
    '''
    texto = limpiar_codigo(archivo.read_text(encoding='utf-8'))
    encontrado = re.search(r'enum\s+posibles_Estados\s*\{(.*?)\}', texto, re.S)
    if not encontrado:
        return []
    estados = []
    for valor in encontrado.group(1).split(','):
        nombre = re.match(r'\s*(\w+)', valor)
        if nombre:
            estados.append(nombre.group(1))
    return estados


def bases_de_nombres(nombres):
    '''Indexa los nombres por su último componente.

    Parámetros:
    - nombres (set[str]): nombres completos de funciones.

    Retorna:
    - dict[str, set[str]]: último componente → nombres completos.
    '''
    bases = defaultdict(set)
    for nombre in nombres:
        bases[nombre.split('.')[-1]].add(nombre)
    return bases


def resolver_llamada(llamado, contexto, nombres, tipos, bases):
    '''Convierte el texto de una llamada en el nombre de una nota existente.

    Parámetros:
    - llamado (str): nombre tal como aparece en el código.
    - contexto (str | None): struct de la función que llama.
    - nombres (set[str]): nombres completos de funciones.
    - tipos (dict[str, str]): objeto → tipo.
    - bases (dict[str, set[str]]): índice por último componente.

    Retorna:
    - str | None: nombre completo de la función llamada, o None.
    '''
    if llamado in nombres:
        return llamado
    if contexto and f'{contexto}.{llamado}' in nombres:
        return f'{contexto}.{llamado}'
    if '::' in llamado:
        cualificado = llamado.replace('::', '.')
        if cualificado in nombres:
            return cualificado
    candidatos = bases.get(llamado, set())
    if len(candidatos) == 1:
        return next(iter(candidatos))
    return None


def llamadas_de(cuerpo, cuerpo_limpio, contexto, nombres, tipos, bases):
    '''Deduce las funciones del mapa a las que llama un cuerpo de código.

    Parámetros:
    - cuerpo (str): cuerpo original.
    - cuerpo_limpio (str): cuerpo sin comentarios ni literales.
    - contexto (str | None): struct de la función.
    - nombres (set[str]): nombres completos de funciones.
    - tipos (dict[str, str]): objeto → tipo.
    - bases (dict[str, set[str]]): índice por último componente.

    Retorna:
    - set[str]: nombres completos de las funciones llamadas.
    '''
    llamadas = set()
    for encontrado in re.finditer(
            r'(?<![\w.])([A-Za-z_]\w*(?:::[A-Za-z_]\w*)*)\s*\(', cuerpo_limpio):
        llamado = encontrado.group(1)
        if llamado in PALABRAS_RESERVADAS:
            continue
        destino = resolver_llamada(llamado, contexto, nombres, tipos, bases)
        if destino:
            llamadas.add(destino)
    for objeto, metodo in re.findall(r'\b(\w+)\.(\w+)\s*\(', cuerpo_limpio):
        tipo = tipos.get(objeto)
        destino = None
        if tipo and f'{tipo}.{metodo}' in nombres:
            destino = f'{tipo}.{metodo}'
        elif not tipo and not objeto[0].isupper():  # Serial.begin, Wire.begin: del core
            # Objeto local sin tipo conocido: se resuelve por el nombre del método.
            # Con un tipo global ajeno (prefs.begin de Preferences) no se enlaza.
            destino = resolver_llamada(metodo, contexto, nombres, tipos, bases)
        if destino:
            llamadas.add(destino)
    for registrada in re.findall(
            r'attachInterrupt\s*\([^,]+,\s*([A-Za-z_]\w*)', cuerpo_limpio):
        destino = resolver_llamada(registrada, contexto, nombres, tipos, bases)
        if destino:
            llamadas.add(destino)
    return llamadas


def analizar(funciones, tipos):
    '''Deduce las relaciones entre funciones del firmware.

    Parámetros:
    - funciones (list[dict]): lo que devuelve buscar_funciones.
    - tipos (dict[str, str]): lo que devuelve buscar_globales.

    Retorna:
    - dict: relaciones listas para escribir las notas.
    '''
    nombres = {f['nombre'] for f in funciones}
    bases = bases_de_nombres(nombres)
    llama = defaultdict(set)
    llamada_por = defaultdict(set)
    for funcion in funciones:
        nombre = funcion['nombre']
        for destino in llamadas_de(funcion['cuerpo'], funcion['cuerpo_limpio'],
                                   funcion['struct'], nombres, tipos, bases):
            if destino != nombre:
                llama[nombre].add(destino)
    for origen, destinos in llama.items():
        for destino in destinos:
            llamada_por[destino].add(origen)
    return {'llama': llama, 'llamada_por': llamada_por, 'bases': bases}


def ramas_if(funcion):
    '''Recorre las ramas if/else-if de una función con sus condiciones y cuerpos.

    Las posiciones del cuerpo limpio y del original coinciden, así que la
    condición y el bloque se pueden leer del texto original sin perder los
    literales de texto.

    Parámetros:
    - funcion (dict): función con cuerpo y cuerpo_limpio.

    Retorna:
    - list[tuple[str, str, str]]: condición, bloque original y bloque limpio.
    '''
    original = funcion['cuerpo']
    limpio = funcion['cuerpo_limpio']
    ramas = []
    for encontrado in re.finditer(r'\bif\s*\(', limpio):
        apertura = encontrado.end() - 1
        profundidad = 0
        cierre = apertura
        for cierre in range(apertura, len(limpio)):
            if limpio[cierre] == '(':
                profundidad += 1
            elif limpio[cierre] == ')':
                profundidad -= 1
                if profundidad == 0:
                    break
        condicion = original[apertura + 1:cierre]
        posicion = cierre + 1
        while posicion < len(limpio) and limpio[posicion].isspace():
            posicion += 1
        if posicion < len(limpio) and limpio[posicion] == '{':
            fin = fin_de_bloque(limpio, posicion)
        else:
            fin = limpio.find(';', posicion)
            if fin < 0:
                fin = len(limpio) - 1
        ramas.append((condicion, original[posicion:fin + 1],
                      limpio[posicion:fin + 1]))
    return ramas


def buscar_mensaje_ble(archivo):
    '''Lee el programa BLE de ejemplo con que arranca el firmware.

    Parámetros:
    - archivo (Path): CodigoESP32.ino.

    Retorna:
    - str: valor por defecto de mensajeBLE, o cadena vacía.
    '''
    texto = archivo.read_text(encoding='utf-8')
    encontrado = re.search(r'\bmensajeBLE\s*=\s*"([^"]*)"', texto)
    return encontrado.group(1) if encontrado else ''


def buscar_instrucciones(funciones):
    '''Saca los códigos del protocolo BLE de Interpreta_mensajeBLE.

    Reconoce los bloques de control de 5 letras (comando == "XXXXX") y los de
    2 letras más 3 dígitos de valor (instruccion == "XX"). Para cada código
    guarda la constante inst_... que encola su rama, si hay alguna.

    Parámetros:
    - funciones (list[dict]): funciones encontradas.

    Retorna:
    - dict[str, dict]: código → tipo, constante y formato.
    '''
    funcion = next((f for f in funciones if f['nombre'] == 'Interpreta_mensajeBLE'), None)
    instrucciones = {}
    if not funcion:
        return instrucciones
    for condicion, bloque, _ in ramas_if(funcion):
        codigos = []
        codigos.extend(('bloque', c) for c in
                       re.findall(r'comando\s*==\s*"([^"]+)"', condicion))
        codigos.extend(('valor', c) for c in
                       re.findall(r'instruccion\s*==\s*"([^"]+)"', condicion))
        constante = re.search(r'\binst_([A-Z]\w*)', bloque)
        for tipo, codigo in codigos:
            anterior = instrucciones.get(codigo, {})
            instrucciones[codigo] = {
                'codigo': codigo,
                'tipo': tipo,
                'constante': (f'inst_{constante.group(1)}' if constante
                              else anterior.get('constante')),
                'formato': (f'`{codigo}` + `010` = valor' if tipo == 'valor'
                            else 'bloque de control de 5 letras sin valor'),
            }
    return instrucciones


MENSAJES_CONOCIDOS = [
    'ERROR CONFIG', 'ERROR PWM', 'VERIFY ERROR', 'VERIFY OK',
    'PROGRAM_CONTINUE', 'MOTOR_BEGIN', 'MOTOR_DONE', 'TURN_RESULT',
    'MOVE_DONE', 'ENCODERS', 'FAULT', 'BUSY', 'CONFIG', 'T',
]


def cerrar_parentesis(limpio, apertura):
    '''Encuentra el paréntesis que cierra la llamada abierta en apertura.

    Parámetros:
    - limpio (str): código sin comentarios ni literales.
    - apertura (int): posición del paréntesis de apertura.

    Retorna:
    - int: posición del paréntesis de cierre.
    '''
    profundidad = 0
    for posicion in range(apertura, len(limpio)):
        if limpio[posicion] == '(':
            profundidad += 1
        elif limpio[posicion] == ')':
            profundidad -= 1
            if profundidad == 0:
                return posicion
    return len(limpio) - 1


def nombre_de_mensaje(literal):
    '''Encuentra el prefijo fijo de un literal impreso por Serial.

    Parámetros:
    - literal (str): texto del literal, sin comillas.

    Retorna:
    - str | None: nombre del mensaje, o None si no es un mensaje conocido.
    '''
    for prefijo in sorted(MENSAJES_CONOCIDOS, key=len, reverse=True):
        if literal.startswith(prefijo):
            resto = literal[len(prefijo):len(prefijo) + 1]
            if not resto or resto in ',: ':
                return prefijo
    return None


def literales_serial(funcion):
    '''Saca los literales que una función imprime o formatea para Serial.

    Parámetros:
    - funcion (dict): función con cuerpo y cuerpo_limpio.

    Retorna:
    - list[str]: literales encontrados.
    '''
    original = funcion['cuerpo']
    limpio = funcion['cuerpo_limpio']
    literales = []
    patrones = [r'\bSerial\s*\.\s*(?:print|println|printf)\s*\(',
                r'\bsnprintf\s*\(']
    for patron in patrones:
        for encontrado in re.finditer(patron, limpio):
            apertura = encontrado.end() - 1
            cierre = cerrar_parentesis(limpio, apertura)
            llamada = original[apertura:cierre + 1]
            literales.extend(
                re.findall(r'"((?:[^"\\]|\\.)*)"', llamada))
    return literales


def buscar_mensajes(funciones):
    '''Deduce los mensajes serie y las funciones que los emiten.

    Parámetros:
    - funciones (list[dict]): funciones encontradas.

    Retorna:
    - tuple[dict, dict]: mensajes y funciones que emiten cada mensaje.
    '''
    mensajes = {}
    emite = defaultdict(set)
    for funcion in funciones:
        for literal in literales_serial(funcion):
            nombre = nombre_de_mensaje(literal)
            if not nombre:
                continue
            datos = mensajes.setdefault(nombre, {'emisores': set(), 'literales': set()})
            datos['emisores'].add(funcion['nombre'])
            datos['literales'].add(literal)
            emite[funcion['nombre']].add(nombre)
    return mensajes, emite


AUXILIARES_COMANDO = {
    'parseFloatValue', 'within', 'floorf', 'fabsf', 'calibrationIdle',
    'indexOf', 'String', 'toUpperCase', 'trim',
}


def buscar_comandos(funciones, tipos):
    '''Saca los comandos de la consola de processSerialCommand.

    Parámetros:
    - funciones (list[dict]): funciones encontradas.
    - tipos (dict[str, str]): objeto → tipo, para resolver métodos.

    Retorna:
    - dict[str, dict]: comando → función que lo atiende y requisitos.
    '''
    funcion = next((f for f in funciones if f['nombre'] == 'processSerialCommand'), None)
    if not funcion:
        return {}
    nombres = {f['nombre'] for f in funciones}
    bases = bases_de_nombres(nombres)
    comandos = {}
    for condicion, bloque, bloque_limpio in ramas_if(funcion):
        codigos = re.findall(r'upper\s*==\s*"([^"]+)"', condicion)
        codigos.extend(re.findall(r'upper\.startsWith\("([^"]+)"\)', condicion))
        codigos = [c.strip() for c in codigos if c.strip() and c.strip() != '?']
        if not codigos:
            continue
        llamadas = llamadas_de(bloque, bloque_limpio, None, nombres, tipos, bases)
        utiles = sorted(
            c for c in llamadas if c.split('.')[-1] not in AUXILIARES_COMANDO)
        handler = utiles[0] if utiles else 'processSerialCommand'
        for codigo in codigos:
            if codigo == 'DEV':
                handler = 'processSerialCommand'
            comandos[codigo] = {
                'codigo': codigo,
                'handler': handler,
                'dev': codigo not in ('STOP', 'DEV'),
                'quieto': (codigo not in ('STOP', 'DEV', 'EXIT')
                           and not codigo.startswith('TELEMETRY')),
            }
    return comandos


def buscar_columnas_telemetria(archivo):
    '''Lee la lista COLUMNS de capturar_movimiento.py.

    Parámetros:
    - archivo (Path): capturar_movimiento.py.

    Retorna:
    - list[str]: nombres de las columnas de telemetría.
    '''
    texto = archivo.read_text(encoding='utf-8')
    encontrado = re.search(r'\bCOLUMNS\s*=\s*"([^"]+)"', texto)
    return encontrado.group(1).split(',') if encontrado else []


def normalizar_valor(valor):
    '''Limpia comillas y sufijos de tipo de un inicializador.

    Parámetros:
    - valor (str): texto del inicializador.

    Retorna:
    - str: valor legible.
    '''
    valor = valor.strip().rstrip(';').strip()
    if len(valor) >= 2 and valor[0] == valor[-1] and valor[0] in '"\'':
        return valor[1:-1]
    if re.fullmatch(r'[+-]?\d+(?:\.\d+)?[fF]', valor):
        return valor[:-1]
    return valor


def buscar_campos_tabla(texto, nombre):
    '''Lee una tabla de campos SET del RobotConfig.h.

    Parámetros:
    - texto (str): contenido original de RobotConfig.h.
    - nombre (str): nombre del arreglo (motionFields, turnFields o servoFields).

    Retorna:
    - list[tuple[str, str, str | None]]: campo, variable y clave NVS opcional.
    '''
    encontrado = re.search(rf'\b{nombre}\s*\[\s*\]\s*=\s*\{{(.*?)\}}\s*;', texto, re.S)
    if not encontrado:
        return []
    campos = []
    patron = r'\{\s*"([^"]+)"\s*,\s*(?:"([^"]+)"\s*,\s*)?&([\w.]+)\s*\}'
    for entrada in re.finditer(patron, encontrado.group(1)):
        campos.append((entrada.group(1), entrada.group(3), entrada.group(2)))
    return campos


def buscar_globales_config(archivo):
    '''Lee los inicializadores de las variables globales de RobotConfig.h.

    Parámetros:
    - archivo (Path): RobotConfig.h.

    Retorna:
    - dict[str, str]: variable → valor por defecto.
    '''
    tipos = (r'(?:const\s+)?(?:unsigned\s+long|unsigned\s+int|unsigned|long|short|'
             r'int|float|double|bool|String|char\s*\*|const\s+char\s*\*|'
             r'uint\d+_t|int\d+_t)\s+')
    valores = {}
    for linea in archivo.read_text(encoding='utf-8').split('\n'):
        if '(' in linea.split('//')[0]:
            continue
        encontrado = re.match(r'\s*' + tipos + r'(.+?);', linea)
        if not encontrado:
            continue
        for parte in dividir_por_comas(encontrado.group(1)):
            asignacion = re.match(r'\s*\*?\s*(\w+)\s*=\s*(.+)$', parte)
            if asignacion:
                valores[asignacion.group(1)] = normalizar_valor(asignacion.group(2))
    return valores


def dividir_por_comas(texto):
    '''Separa declaraciones por comas sin partir literales de texto.

    Parámetros:
    - texto (str): declaraciones de una misma línea.

    Retorna:
    - list[str]: cada declaración.
    '''
    partes = []
    actual = []
    comillas = None
    for caracter in texto:
        if comillas:
            actual.append(caracter)
            if caracter == comillas:
                comillas = None
        elif caracter in '"\'':
            comillas = caracter
            actual.append(caracter)
        elif caracter == ',':
            partes.append(''.join(actual))
            actual = []
        else:
            actual.append(caracter)
    if actual:
        partes.append(''.join(actual))
    return partes


def buscar_defaults_structs(archivo):
    '''Lee los miembros y valores por defecto de los structs de MotionControl.h.

    Parámetros:
    - archivo (Path): MotionControl.h.

    Retorna:
    - dict[str, dict[str, dict]]: struct → miembro → tipo, valor y comentario.
    '''
    original = archivo.read_text(encoding='utf-8')
    limpio = limpiar_codigo(original)
    structs = {}
    for nombre, apertura, cierre in rangos_de_structs(limpio):
        miembros = {}
        profundidad = 0
        inicio = apertura + 1
        dentro_bloque = False
        for posicion in range(apertura, cierre + 1):
            caracter = limpio[posicion]
            if caracter == '{':
                profundidad += 1
                if profundidad == 2:
                    dentro_bloque = True
            elif caracter == '}':
                profundidad -= 1
                if profundidad == 1:
                    dentro_bloque = False
                    inicio = posicion + 1
            elif caracter == ';' and profundidad == 1 and not dentro_bloque:
                declaracion = limpio[inicio:posicion].strip()
                original_decl = original[inicio:posicion]
                inicio = posicion + 1
                if not declaracion or '(' in declaracion or declaracion.startswith('#'):
                    continue
                encontrado = re.match(r'([A-Za-z_]\w*)\s+(.+)$', declaracion, re.S)
                if not encontrado:
                    continue
                tipo = encontrado.group(1)
                resto = ' '.join(encontrado.group(2).split())
                comentario = ''
                fin_linea = original.find('\n', posicion)
                if fin_linea < 0:
                    fin_linea = len(original)
                comilla = re.search(r'//\s*(.*)', original[posicion:fin_linea])
                if comilla:
                    comentario = comilla.group(1).strip()
                else:
                    comilla = re.search(r'//\s*(.*)', original_decl)
                    if comilla:
                        comentario = comilla.group(1).strip()
                for parte in dividir_por_comas(resto):
                    asignacion = re.match(r'(\w+)\s*(?:=\s*(.+))?$', parte.strip())
                    if not asignacion:
                        continue
                    miembros[asignacion.group(1)] = {
                        'tipo': tipo,
                        'valor': (normalizar_valor(asignacion.group(2))
                                  if asignacion.group(2) else None),
                        'comentario': comentario,
                    }
        structs[nombre] = miembros
    return structs


def valor_de_miembro(structs, tipo_struct, partes):
    '''Resuelve el valor por defecto de una ruta de miembros.

    Parámetros:
    - structs (dict): lo que devuelve buscar_defaults_structs.
    - tipo_struct (str): struct donde empieza la búsqueda.
    - partes (list[str]): miembros que quedan por recorrer.

    Retorna:
    - tuple[str | None, str]: valor por defecto y comentario del miembro final.
    '''
    if not partes or tipo_struct not in structs:
        return None, ''
    miembro = structs[tipo_struct].get(partes[0])
    if not miembro:
        return None, ''
    if len(partes) == 1:
        return miembro['valor'], miembro['comentario']
    return valor_de_miembro(structs, miembro['tipo'], partes[1:])


def rangos_validacion(archivos):
    '''Deduce los rangos de los campos a partir de las funciones de validación.

    Parámetros:
    - archivos (list[Path]): archivos del firmware.

    Retorna:
    - dict[str, tuple[str, str, str]]: miembro → mínimo, máximo y expresión.
    '''
    rangos = {}
    for archivo in archivos:
        if archivo.name not in ('MotionControl.h', 'MotionRuntime.h'):
            continue
        limpio = limpiar_codigo(archivo.read_text(encoding='utf-8'))
        for encontrado in re.finditer(
                r'within\(\s*([\w>-]+(?:\.[\w]+)*)\s*,\s*([^,]+?)\s*,\s*([^)]+)\)', limpio):
            expresion = encontrado.group(1)
            miembro = re.split(r'[.>]+', expresion)[-1]
            rangos[miembro] = (encontrado.group(2).strip(),
                               encontrado.group(3).strip(), expresion)
    return rangos


def rango_de_campo(campo, rangos, structs):
    '''Arma el texto del rango válido de un campo SET.

    Parámetros:
    - campo (dict): datos del campo.
    - rangos (dict): lo que devuelve rangos_validacion.
    - structs (dict): lo que devuelve buscar_defaults_structs.

    Retorna:
    - str: rango legible o la expresión original si no se puede reducir.
    '''
    if campo['tipo'] == 'servo':
        return '0..180 (entero)'
    if campo['campo'] == 'device':
        return 'texto de 1..31 caracteres, sin comas'
    if campo['campo'] == 'pwmhz':
        return campo.get('rango_especial', 'motorPwmMinHz..motorPwmMaxHz')
    miembro = campo['variable'].split('.')[-1]
    if campo['campo'] in ('kp', 'ki', 'kd'):
        miembro = campo['campo']
    datos = rangos.get(miembro)
    if not datos:
        return campo.get('rango_especial', 'no deducido')
    bajo, alto, expresion = datos
    bajo = normalizar_valor(bajo)
    alto = normalizar_valor(alto)
    if re.fullmatch(r'[+-]?\d+(?:\.\d+)?', bajo) and re.fullmatch(r'[+-]?\d+(?:\.\d+)?', alto):
        texto = f'{bajo}..{alto}'
        if miembro == 'startMs':
            texto += ' (menor que stallMs)'
        return texto
    if alto == 'maxPWM':
        defecto = valor_de_miembro(structs, 'MotionConfig', ['maxPWM'])[0]
        return f'{bajo}..maxPWM ({defecto})'
    if alto.endswith('start'):
        defecto = valor_de_miembro(structs, 'WheelConfig', ['forward', 'start'])[0]
        return f'{bajo}..start ({defecto})'
    return f'`{expresion}` → {bajo}..{alto}'


def funciones_que_leen(campo, funciones):
    '''Busca las funciones que leen el miembro o la variable de un campo SET.

    Parámetros:
    - campo (dict): datos del campo.
    - funciones (list[dict]): funciones encontradas.

    Retorna:
    - set[str]: nombres de las funciones que usan el campo.
    '''
    if campo['tipo'] in ('motion', 'turn'):
        miembro = campo['variable'].split('.')[-1]
        if campo['campo'] in ('kp', 'ki', 'kd'):
            miembro = campo['campo']
        patron = r'(?:\.|->)' + re.escape(miembro) + r'\b'
        archivos = {'MotionControl.h', 'MotionRuntime.h'}
        return {f['nombre'] for f in funciones
                if f['archivo'] in archivos and re.search(patron, f['cuerpo_limpio'])}
    miembro = campo['variable']
    if campo['campo'] in ('kp', 'ki', 'kd'):
        miembro = campo['campo']
        patron = r'(?:\.|->)' + re.escape(miembro) + r'\b'
    else:
        patron = r'\b' + re.escape(miembro) + r'\b'
    return {f['nombre'] for f in funciones
            if re.search(patron, f['cuerpo_limpio'])}


def buscar_parametros(funciones, archivos):
    '''Arma la lista de campos que acepta SET <campo> <valor>.

    Parámetros:
    - funciones (list[dict]): funciones encontradas.
    - archivos (list[Path]): archivos del firmware.

    Retorna:
    - list[dict]: campo, variable, defecto, rango, comentario y lectores.
    '''
    config = next(a for a in archivos if a.name == 'RobotConfig.h')
    texto = config.read_text(encoding='utf-8')
    structs = buscar_defaults_structs(next(a for a in archivos
                                           if a.name == 'MotionControl.h'))
    globales = buscar_globales_config(config)
    rangos = rangos_validacion(archivos)
    parametros = []

    def agregar(campo, variable, tipo, defecto, comentario, rango_especial=None,
                archivo='CodigoESP32'):
        '''Agrega un campo SET con su rango y sus lectores.

        Parámetros:
        - campo (str): nombre que escribe el comando SET.
        - variable (str): variable o miembro de destino.
        - tipo (str): motion, turn, servo o especial.
        - defecto (str | None): valor por defecto.
        - comentario (str | None): texto del miembro o aclaración.
        - rango_especial (str | None): rango ya resuelto para casos especiales.
        - archivo (str): archivo de origen del dato.

        Retorna: None.
        '''
        datos = {
            'campo': campo,
            'variable': variable,
            'tipo': tipo,
            'defecto': defecto if defecto is not None else '?',
            'comentario': comentario or '',
            'rango_especial': rango_especial,
            'archivo': archivo,
        }
        datos['rango'] = rango_de_campo(datos, rangos, structs)
        datos['leen'] = funciones_que_leen(datos, funciones)
        parametros.append(datos)

    for nombre, variable, _ in buscar_campos_tabla(texto, 'motionFields'):
        partes = variable.split('.')[1:]
        defecto, comentario = valor_de_miembro(structs, 'MotionConfig', partes)
        agregar(nombre, variable, 'motion', defecto, comentario)
    for nombre, variable, _ in buscar_campos_tabla(texto, 'turnFields'):
        partes = variable.split('.')[1:]
        defecto, comentario = valor_de_miembro(structs, 'TurnConfig', partes)
        agregar(nombre, variable, 'turn', defecto, comentario)
    for nombre, variable, _ in buscar_campos_tabla(texto, 'servoFields'):
        agregar(nombre, variable, 'servo', globales.get(variable),
                'ángulo del servo, entero de 0 a 180')
    minimo = globales.get('motorPwmMinHz', '?')
    maximo = globales.get('motorPwmMaxHz', '?')
    agregar('pwmhz', 'motorPwmHz', 'especial', globales.get('motorPwmHz'),
            'frecuencia PWM de los motores; se aplica al reiniciar',
            f'{minimo}..{maximo} (entero)')
    agregar('device', 'deviceName', 'especial', globales.get('deviceName'),
            'nombre Bluetooth; se aplica al reiniciar')
    for alias in ('kp', 'ki', 'kd'):
        defecto = valor_de_miembro(structs, 'WheelConfig', [alias])[0]
        agregar(alias, f'motionConfig.right.{alias} y motionConfig.left.{alias}',
                'especial', defecto, 'alias que escribe la misma ganancia en las dos ruedas')
    parametros.sort(key=lambda p: p['campo'])
    return parametros


def destinos_de_estado(texto, conjunto):
    '''Saca los estados que asigna un fragmento, incluidas ternarias.

    Parámetros:
    - texto (str): código sin comentarios ni literales.
    - conjunto (set[str]): estados válidos del enum.

    Retorna:
    - set[str]: estados asignados en el fragmento.
    '''
    destinos = set()
    for encontrado in re.finditer(r'\bestado\s*=(?!=)\s*([^;]+)', texto):
        for nombre in re.findall(r'\b([A-Z][A-Z0-9_]*)\b', encontrado.group(1)):
            if nombre in conjunto:
                destinos.add(nombre)
    return destinos


def analizar_estados(funciones, estados):
    '''Deduce las transiciones y los responsables de cada estado de loop().

    Los estados no son funciones: cada uno es un case del switch (estado). Las
    transiciones salen de las asignaciones estado = X dentro del case, y las
    funciones que asignan un estado se buscan fuera de loop().

    Parámetros:
    - funciones (list[dict]): funciones encontradas.
    - estados (list[str]): nombres del enum posibles_Estados.

    Retorna:
    - dict: transiciones, funciones que asignan estados y llamadas de cada case.
    '''
    nombres = {f['nombre'] for f in funciones}
    bases = bases_de_nombres(nombres)
    conjunto = set(estados)
    principal = next((f for f in funciones
                      if f['nombre'] == 'loop' and f['archivo'] == 'CodigoESP32.ino'),
                     None)
    puede_seguir = defaultdict(set)
    llama_caso = defaultdict(set)
    casos = set()
    if principal:
        cuerpo = principal['cuerpo_limpio']
        original = principal['cuerpo']
        for encontrado in re.finditer(r'case\s+(\w+)\s*:', cuerpo):
            estado = encontrado.group(1)
            if estado not in conjunto:
                continue
            casos.add(estado)
            posicion = encontrado.end()
            while posicion < len(cuerpo) and cuerpo[posicion].isspace():
                posicion += 1
            if posicion < len(cuerpo) and cuerpo[posicion] == '{':
                cierre = fin_de_bloque(cuerpo, posicion)
                bloque_limpio = cuerpo[posicion:cierre + 1]
                bloque = original[posicion:cierre + 1]
            else:
                siguiente = cuerpo.find('case ', posicion)
                cierre = siguiente if siguiente >= 0 else len(cuerpo)
                bloque_limpio = cuerpo[posicion:cierre]
                bloque = original[posicion:cierre]
            for destino in destinos_de_estado(bloque_limpio, conjunto):
                if destino != estado:
                    puede_seguir[estado].add(destino)
            for destino in llamadas_de(bloque, bloque_limpio, None, nombres, {}, bases):
                llama_caso[estado].add(destino)
    viene_de = defaultdict(set)
    for origen, destinos in puede_seguir.items():
        for destino in destinos:
            viene_de[destino].add(origen)
    asignan_estado = defaultdict(set)
    asigna_funcion = defaultdict(set)
    for funcion in funciones:
        if funcion is principal:
            continue
        for destino in destinos_de_estado(funcion['cuerpo_limpio'], conjunto):
            asignan_estado[destino].add(funcion['nombre'])
            asigna_funcion[funcion['nombre']].add(destino)
    return {
        'puede_seguir': puede_seguir,
        'viene_de': viene_de,
        'asignan_estado': asignan_estado,
        'asigna_estado': asigna_funcion,
        'llama_caso': llama_caso,
        'casos': casos,
        'sin_case': conjunto - casos,
    }


def enlace(nombre):
    '''Arma el enlace a una función, o su nombre en código si es utilitaria.

    Parámetros:
    - nombre (str): nombre de la función.

    Retorna:
    - str: [[nombre]] o nombre entre comillas invertidas.
    '''
    return f'`{nombre}`' if nombre in UTILITARIAS else f'[[{nombre}]]'


def lista(titulo, elementos):
    '''Arma una sección de la nota con una lista, o nada si está vacía.

    Parámetros:
    - titulo (str): encabezado de la sección.
    - elementos (iterable[str]): renglones ya formateados.

    Retorna:
    - str: la sección en markdown, o cadena vacía.
    '''
    elementos = sorted(elementos)
    if not elementos:
        return ''
    return f'\n## {titulo}\n' + '\n'.join(f'- {e}' for e in elementos) + '\n'


def escribir(ruta, etiqueta, cuerpo, extra=''):
    '''Escribe una nota con su frontmatter.

    Parámetros:
    - ruta (Path): archivo de la nota.
    - etiqueta (str): tag de Obsidian, que decide el color en el grafo.
    - cuerpo (str): contenido en markdown.
    - extra (str): líneas adicionales para el frontmatter.

    Retorna: None.
    '''
    ruta.parent.mkdir(parents=True, exist_ok=True)
    ruta.write_text(f'---\ntags: [{etiqueta}]\n{extra}---\n{cuerpo}', encoding='utf-8')


def escribir_funciones(base, funciones, rel, modelo):
    '''Escribe una nota por cada función documentada.

    Parámetros:
    - base (Path): carpeta Mapa/.
    - funciones (list[dict]): funciones encontradas.
    - rel (dict): relaciones de analizar().
    - modelo (dict): datos deducidos del firmware.

    Retorna: None.
    '''
    for funcion in funciones:
        nombre = funcion['nombre']
        if nombre in UTILITARIAS:
            continue
        cuerpo = f'# {nombre}\n\n'
        if funcion['doc']:
            cuerpo += '\n'.join('> ' + linea if linea else '>'
                                for linea in funcion['doc'].split('\n')) + '\n\n'
        else:
            cuerpo += '> Sin documentar.\n\n'
        cuerpo += f'**Archivo:** [[{funcion["archivo"]}]] · línea {funcion["linea"]}\n\n'
        lenguaje = 'python' if funcion['archivo'].endswith('.py') else 'cpp'
        cuerpo += f'```{lenguaje}\n{funcion["firma"]}\n```\n'
        cuerpo += lista('Llama a', [enlace(x) for x in rel['llama'][nombre]])
        cuerpo += lista('La llaman', [enlace(x) for x in rel['llamada_por'][nombre]])
        cuerpo += lista(
            'Emite',
            [f'[[Mensaje {m}]]' for m in rel.get('emite', {}).get(nombre, set())])
        cuerpo += lista(
            'Campos SET que usa',
            [f'[[SET {p["campo"]}]]' for p in modelo['parametros']
             if nombre in p['leen']])
        cuerpo += lista(
            'Estados que asigna',
            [f'[[Estado {e}]]' for e in rel.get('asigna_estado', {}).get(nombre, set())])
        etiqueta = 'metodo' if funcion['metodo'] else 'funcion'
        escribir(base / 'Funciones' / f'{nombre}.md', etiqueta, cuerpo,
                 f'archivo: {funcion["archivo"]}\nlinea: {funcion["linea"]}\n')


def escribir_comandos(base, modelo):
    '''Escribe una nota por cada comando de la consola serie.

    Parámetros:
    - base (Path): carpeta Mapa/.
    - modelo (dict): datos deducidos del firmware.

    Retorna: None.
    '''
    for codigo, datos in modelo['comandos'].items():
        if datos['handler'] == 'processSerialCommand':
            atiende = ('Lo atiende [[processSerialCommand]] directamente; la rama no '
                       'tiene una función propia en el mapa. Consola serie (115200).')
        else:
            atiende = (f'Lo atiende {enlace(datos["handler"])}, desde '
                       '[[processSerialCommand]] en la consola serie (115200).')
        cuerpo = (f'# Comando {codigo}\n\n{atiende}\n\n'
                  f'- Requiere modo DEV: {"sí" if datos["dev"] else "no"}.\n'
                  f'- Requiere robot detenido (`calibrationIdle()`): '
                  f'{"sí" if datos["quieto"] else "no"}.\n')
        if codigo == 'SET':
            cuerpo += '\nEl campo y el valor se validan y guardan; ver [[Parámetros SET]].\n'
        escribir(base / 'Comandos serie' / f'Comando {codigo}.md', 'comando', cuerpo)


def escribir_mensajes(base, modelo):
    '''Escribe una nota por cada mensaje que sale por Serial.

    Parámetros:
    - base (Path): carpeta Mapa/.
    - modelo (dict): datos deducidos del firmware.

    Retorna: None.
    '''
    for nombre, datos in modelo['mensajes'].items():
        cuerpo = f'# Mensaje {nombre}\n\n'
        if nombre == 'T':
            cuerpo += ('Fila CSV de telemetría que se activa con `TELEMETRY ON` y se '
                       'imprime cada 100 ms. La guarda [[capturar_movimiento.main]] '
                       'en un CSV.\n')
        else:
            cuerpo += 'Texto que el firmware imprime por Serial.\n'
        cuerpo += lista('Lo emiten', [enlace(x) for x in datos['emisores']])
        cuerpo += lista('Literales', [f'`{x}`' for x in datos['literales']])
        if nombre == 'T' and modelo['columnas_telemetria']:
            cuerpo += '\n## Columnas\n'
            cuerpo += '\n'.join(
                f'{i}. `{columna}`' for i, columna in
                enumerate(modelo['columnas_telemetria'], 1)) + '\n'
        escribir(base / 'Mensajes serie' / f'Mensaje {nombre}.md', 'mensaje', cuerpo)


def escribir_parametros(base, modelo):
    '''Escribe una nota por campo SET y su índice en tabla.

    Parámetros:
    - base (Path): carpeta Mapa/.
    - modelo (dict): datos deducidos del firmware.

    Retorna: None.
    '''
    for parametro in modelo['parametros']:
        campo = parametro['campo']
        cuerpo = (f'# SET {campo}\n\n'
                  f'**Variable destino:** `{parametro["variable"]}` · '
                  f'**Defecto:** `{parametro["defecto"]}` · '
                  f'**Rango:** `{parametro["rango"]}`\n\n')
        if parametro['comentario']:
            cuerpo += f'> {parametro["comentario"]}\n\n'
        cuerpo += ('Se guarda con [[saveDeveloperValue]]: valida el valor, escribe '
                   'la NVS y vuelve a verificar la configuración. '
                   'Ver [[Parámetros SET]].\n')
        cuerpo += lista('Lo leen', [enlace(x) for x in parametro['leen']])
        escribir(base / 'Parámetros SET' / f'SET {campo}.md', 'parametro', cuerpo)
    lineas = ['# Parámetros SET', '',
              'Campos que acepta `SET <campo> <valor>` en modo desarrollador. '
              'Los atiende [[saveDeveloperValue]]; los perfiles se guardan en la NVS '
              'como `motionV2` y `turnV1`.', '',
              '| campo | defecto | rango |',
              '| --- | --- | --- |']
    for parametro in modelo['parametros']:
        lineas.append(f'| [[SET {parametro["campo"]}]] | `{parametro["defecto"]}` | '
                      f'`{parametro["rango"]}` |')
    escribir(base / 'Parámetros SET' / 'Parámetros SET.md', 'indice',
             '\n'.join(lineas) + '\n')


def escribir_instrucciones(base, modelo):
    '''Escribe una nota por cada código del protocolo BLE.

    Parámetros:
    - base (Path): carpeta Mapa/.
    - modelo (dict): datos deducidos del firmware.

    Retorna: None.
    '''
    for codigo, datos in modelo['instrucciones'].items():
        cuerpo = f'# Instruccion {codigo}\n\n'
        cuerpo += (f'Código del programa BLE con formato {datos["formato"]}. '
                   'Lo interpreta [[Interpreta_mensajeBLE]].\n')
        if datos['constante']:
            cuerpo += f'\n## Encola\n- `{datos["constante"]}`\n'
        else:
            cuerpo += ('\nNo encola ninguna constante `inst_...`: la rama solo '
                       'ajusta banderas o punteros, o deja la asignación comentada.\n')
        escribir(base / 'Instrucciones BLE' / f'Instruccion {codigo}.md',
                 'instruccion', cuerpo)


def escribir_estados(base, modelo):
    '''Escribe una nota por cada estado del enum posibles_Estados.

    Parámetros:
    - base (Path): carpeta Mapa/.
    - modelo (dict): datos deducidos del firmware.

    Retorna: None.
    '''
    rel = modelo['rel']
    for estado in modelo['estados']:
        cuerpo = f'# Estado {estado}\n\n'
        if estado in rel['casos']:
            cuerpo += f'Es el `case {estado}:` de [[loop]], dentro del `switch (estado)`.\n'
        else:
            cuerpo += 'No tiene `case X:` dentro del `switch (estado)` de [[loop]].\n'
        cuerpo += lista('Puede seguir con',
                        [f'[[Estado {x}]]' for x in rel['puede_seguir'][estado]])
        cuerpo += lista('Viene de',
                        [f'[[Estado {x}]]' for x in rel['viene_de'][estado]])
        cuerpo += lista('Lo asignan',
                        [enlace(x) for x in rel['asignan_estado'][estado]])
        cuerpo += lista('Llama a', [enlace(x) for x in rel['llama_caso'][estado]])
        escribir(base / 'Estados' / f'Estado {estado}.md', 'estado', cuerpo)


def escribir_archivos(base, archivos, funciones):
    '''Escribe una nota índice por cada archivo leído.

    Parámetros:
    - base (Path): carpeta Mapa/.
    - archivos (list[Path]): archivos fuente.
    - funciones (list[dict]): funciones encontradas.

    Retorna: None.
    '''
    for archivo in archivos:
        lineas = archivo.read_text(encoding='utf-8').split('\n')
        cabecera_texto = cabecera(archivo, lineas)
        propias = [f for f in funciones if f['archivo'] == archivo.name]
        cuerpo = f'# {archivo.name}\n\n'
        if cabecera_texto:
            cuerpo += cabecera_texto + '\n\n'
        cuerpo += '## Funciones\n'
        if propias:
            cuerpo += '\n'.join(
                f'- {enlace(f["nombre"])} (línea {f["linea"]})' for f in propias) + '\n'
        escribir(base / 'Archivos' / f'{archivo.name}.md', 'indice', cuerpo)


def escribir_indice(base, modelo):
    '''Escribe el índice general del mapa.

    Parámetros:
    - base (Path): carpeta Mapa/.
    - modelo (dict): datos deducidos del firmware.

    Retorna: None.
    '''
    archivos = modelo['archivos']
    estados = modelo['estados']
    instrucciones = sorted(modelo['instrucciones'])
    comandos = sorted(modelo['comandos'])
    mensajes = sorted(modelo['mensajes'])
    texto = (
        '# Mapa del firmware Atta-Bot STEM\n\n'
        'Generado desde el código por `Robot/tools/mapa_obsidian.py`. No editar a mano: '
        'se reescribe en cada corrida.\n\n'
        '**Cómo leerlo:** la app manda el programa por BLE → [[Interpreta_mensajeBLE]] '
        'llena `lista_instrucciones` → [[loop]] recorre los estados. La calibración entra '
        'por Serie → [[readDeveloperSerial]] → [[processSerialCommand]] → '
        '[[saveDeveloperValue]] → NVS.\n\n'
        'Colores del grafo: funciones azul, métodos celeste, estados naranja, '
        'instrucciones morado, comandos verde, mensajes rojo y parámetros amarillo. '
        'El grafo oculta las notas de índice con el filtro `-tag:#indice`. Las funciones '
        'utilitarias (' + ', '.join(f'`{u}`' for u in sorted(UTILITARIAS)) +
        ') no se enlazan porque las llama casi todo.\n\n'
        '## Archivos\n' +
        '\n'.join(f'- [[{archivo.name}]]' for archivo in archivos) + '\n'
        '\n## Estados\n' +
        ('\n'.join(f'- [[Estado {e}]]' for e in estados) + '\n' if estados else '')
    )
    if modelo['mensaje_ble']:
        texto += ('\nEjemplo de programa BLE (valor por defecto de `mensajeBLE`): '
                  f'`{modelo["mensaje_ble"]}`\n')
    if instrucciones:
        texto += '\n## Instrucciones BLE\n' + '\n'.join(
            f'- [[Instruccion {i}]]' for i in instrucciones) + '\n'
    if comandos:
        texto += '\n## Comandos serie\n' + '\n'.join(
            f'- [[Comando {c}]]' for c in comandos) + '\n'
    if mensajes:
        texto += '\n## Mensajes serie\n' + '\n'.join(
            f'- [[Mensaje {m}]]' for m in mensajes) + '\n'
    texto += '\n## Parámetros SET\n- [[Parámetros SET]]\n'
    texto += '\n## Guías\n' + '\n'.join(f'- [[{g}]]' for g in GUIAS) + '\n'
    escribir(base / 'Índice.md', 'indice', texto)


def escribir_vault(salida, modelo):
    '''Escribe todas las notas del mapa y el índice.

    Parámetros:
    - salida (Path): carpeta Mapa/.
    - modelo (dict): datos deducidos del firmware.

    Retorna: None.
    '''
    if salida.exists():
        # Solo se borra una carpeta vacía o un mapa que generó este script: un --salida
        # equivocado no debe llevarse otra carpeta.
        indice = salida / 'Índice.md'
        generado = indice.is_file() and 'mapa_obsidian.py' in indice.read_text(encoding='utf-8')
        if any(salida.iterdir()) and not generado:
            raise SystemExit(f'{salida} no es un mapa generado; no se borra. Use otra --salida.')
        shutil.rmtree(salida)
    base = salida
    escribir_funciones(base, modelo['funciones'], modelo['rel'], modelo)
    escribir_estados(base, modelo)
    escribir_parametros(base, modelo)
    escribir_instrucciones(base, modelo)
    escribir_mensajes(base, modelo)
    escribir_comandos(base, modelo)
    escribir_archivos(base, modelo['archivos'], modelo['funciones'])
    escribir_indice(base, modelo)


def configurar_grafo():
    '''Fija los colores del grafo por tipo de nota y el filtro de índices.

    Conserva el resto de la configuración que el usuario haya cambiado en
    Obsidian. Si Obsidian está abierto hay que reabrir la vista de grafo.

    Parámetros: ninguno.

    Retorna: None.
    '''
    config = ROBOT / '.obsidian' / 'graph.json'
    config.parent.mkdir(parents=True, exist_ok=True)
    try:
        ajustes = json.loads(config.read_text(encoding='utf-8'))
    except (OSError, ValueError):
        ajustes = {}
    ajustes['colorGroups'] = [
        {'query': f'tag:#{tag}', 'color': {'a': 1, 'rgb': rgb}}
        for tag, rgb in COLORES_GRAFO.items()
    ]
    ajustes['search'] = FILTRO_GRAFO
    ajustes.setdefault('showTags', False)
    config.write_text(json.dumps(ajustes, indent=2) + '\n', encoding='utf-8')
    app = ROBOT / '.obsidian' / 'app.json'
    if not app.exists():
        app.write_text(json.dumps({'userIgnoreFilters': GUIA_IGNORADOS},
                                  ensure_ascii=False) + '\n', encoding='utf-8')


def leer_modelo():
    '''Lee los archivos del firmware y arma el modelo de datos del mapa.

    Parámetros: ninguno.

    Retorna:
    - dict: funciones, relaciones, archivos y datos deducidos.
    '''
    archivos = ARCHIVOS
    funciones = []
    for archivo in archivos:
        if archivo.suffix == '.py':
            funciones.extend(buscar_funciones_python(archivo))
        else:
            funciones.extend(buscar_funciones(archivo))
    tipos = buscar_globales(archivos)
    estados = buscar_estados(ARCHIVOS[0])
    mensajes, emite = buscar_mensajes(funciones)
    rel = analizar(funciones, tipos)
    rel.update(analizar_estados(funciones, estados))
    rel['emite'] = emite
    return {
        'archivos': archivos,
        'funciones': funciones,
        'tipos': tipos,
        'rel': rel,
        'estados': estados,
        'instrucciones': buscar_instrucciones(funciones),
        'parametros': buscar_parametros(funciones, archivos),
        'mensajes': mensajes,
        'comandos': buscar_comandos(funciones, tipos),
        'columnas_telemetria': buscar_columnas_telemetria(
            next(a for a in archivos if a.name == 'capturar_movimiento.py')),
        'mensaje_ble': buscar_mensaje_ble(ARCHIVOS[0]),
    }


def revisar_enlaces(salida):
    '''Verifica que cada [[enlace]] del mapa apunte a una nota existente.

    Las notas pueden estar dentro del mapa o en cualquier otro .md del vault
    Robot/. Un enlace roto es un aviso para corregir el script o el código.

    Parámetros:
    - salida (Path): carpeta del mapa.

    Retorna:
    - list[str]: enlaces rotos, como ruta: enlace.
    '''
    existentes = {archivo.name[:-3]
                  for archivo in list(salida.rglob('*.md')) + list(ROBOT.rglob('*.md'))
                  if archivo.name.endswith('.md')}
    rotos = []
    patron = re.compile(r'\[\[([^\]]+)\]\]')
    for nota in sorted(salida.rglob('*.md')):
        texto = nota.read_text(encoding='utf-8')
        for encontrado in patron.finditer(texto):
            destino = encontrado.group(1).split('|')[0].split('#')[0].strip()
            if destino and destino not in existentes:
                rotos.append(f'{nota.relative_to(salida)}: [[{destino}]]')
    return rotos


def main():
    '''Lee el firmware y escribe el vault de Obsidian.

    Parámetros: ninguno.

    Retorna:
    - int: 0 si terminó bien, 1 si --revisar encontró enlaces rotos.
    '''
    parser = argparse.ArgumentParser(description='Mapa del firmware como vault de Obsidian.')
    parser.add_argument('--salida', type=Path, default=SALIDA_POR_DEFECTO,
                        help=f'carpeta del mapa (por defecto {SALIDA_POR_DEFECTO})')
    parser.add_argument('--revisar', action='store_true',
                        help='después de generar, verifica que no haya enlaces rotos')
    args = parser.parse_args()
    salida = args.salida.expanduser()
    modelo = leer_modelo()
    escribir_vault(salida, modelo)
    configurar_grafo()
    enlaces = sum(len(v) for v in modelo['rel']['llama'].values())
    print(f'Mapa escrito en {salida}')
    print(f'  {len(modelo["funciones"])} funciones, {len(modelo["estados"])} estados, '
          f'{len(modelo["instrucciones"])} instrucciones, {len(modelo["comandos"])} comandos, '
          f'{len(modelo["mensajes"])} mensajes, {len(modelo["parametros"])} parámetros, '
          f'{enlaces} llamadas')
    if args.revisar:
        rotos = revisar_enlaces(salida)
        if rotos:
            print(f'Enlaces rotos: {len(rotos)}')
            for roto in rotos:
                print(f'  {roto}')
            return 1
        print('Enlaces revisados: 0 rotos')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
