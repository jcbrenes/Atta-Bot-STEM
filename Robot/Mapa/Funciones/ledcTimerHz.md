---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 297
---
# ledcTimerHz

> Frecuencia real del temporizador LEDC de un pin. ledcReadFreq() del core 3.x
> devuelve 0 mientras el duty sea 0 (siempre al arrancar), así que no sirve
> para verificar la configuración de los motores.
> Devuelve la frecuencia real del temporizador LEDC asociado a un pin.
>
> ledcReadFreq() del core 3.x devuelve 0 mientras el duty sea 0 (siempre al arrancar), así
> que no sirve para verificar la configuración de los motores. Esta función obtiene el bus
> LEDC del pin con perimanGetPinBus y consulta ledc_get_freq() del canal y temporizador.
>
> @param pin Número de GPIO configurado con ledcAttach.
>
> @return Frecuencia en Hz, o 0 si el pin no tiene un bus LEDC asociado.

**Archivo:** [[CodigoESP32.ino]] · línea 297

```cpp
uint32_t ledcTimerHz(uint8_t pin)
```

## La llaman
- [[attachMotorPWM]]
