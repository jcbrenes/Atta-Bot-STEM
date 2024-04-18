using Atta_Bots_Kids;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


public static class Globals
{
    public enum Funciones { 
        Avanzar, 
        Retroceder,
        Izquierda,
        Derecha,
        Obstaculo,
        Ciclo,
        Pausa,
        Play
    }
    public static string[] codigos = { "del", "atr", "izq", "der", "obs", "rep","stp","ply" };
    public static string[] desarrolladores = { "Isaac David Ortega Arguedas" };
    public static int tamanioInstrucciones = 60;
    private static int posicionInstrucciones = 5;
    public static int PosicionInstrucciones
    {
        get
        {
            return posicionInstrucciones;
        }
        set
        {
            posicionInstrucciones = value;
        }
    }
    public static int espacioEntreInstrucciones = 5;
    private static int cantInstrucciones = 0;
    public static int CantInstrucciones
    {
        get
        {
            return cantInstrucciones;
        }
        set 
        { 
            cantInstrucciones = value;
        }
    }
    public static void agregarInstruccion()
    {
        cantInstrucciones++;
    }
    public static void eliminarInstruccion()
    {
        cantInstrucciones--;
    }
    private static int posCiclo;
    public static int posicionCiclo
    {
        get
        {
            return posCiclo;
        }
        set
        {
            posCiclo = value;
        }
    }
    public static int limiteInstrucciones = 20;

    public static string nombrePuerto = "COM6";
    public static int velocidadPuerto = 9600;
    public static string version = "1.0.0";
    public static string urlManualUsuario = "https://github.com/jcbrenes/PROE/blob/Atta-Bots-Kids/Atta-Bot%20Educativo/Practica_Profesional___Manual_de_usuario.pdf";
}
