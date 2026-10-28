---
tags: [parametro]
---
# SET pwmhz

**Variable destino:** `motorPwmHz` · **Defecto:** `20000` · **Rango:** `200..30000 (entero)`

> frecuencia PWM de los motores; se aplica al reiniciar

Se guarda con [[saveDeveloperValue]]: valida el valor, escribe la NVS y vuelve a verificar la configuración. Ver [[Parámetros SET]].

## Lo leen
- [[attachMotorPWM]]
- [[loadConfig]]
- [[printDeveloperConfig]]
- [[saveDeveloperValue]]
- [[verifyConfig]]
