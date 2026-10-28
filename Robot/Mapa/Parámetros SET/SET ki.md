---
tags: [parametro]
---
# SET ki

**Variable destino:** `motionConfig.right.ki y motionConfig.left.ki` · **Defecto:** `0.8` · **Rango:** `0..100`

> alias que escribe la misma ganancia en las dos ruedas

Se guarda con [[saveDeveloperValue]]: valida el valor, escribe la NVS y vuelve a verificar la configuración. Ver [[Parámetros SET]].

## Lo leen
- [[migrateGains]]
- [[saveDeveloperValue]]
- [[validWheel]]
- [[wheelPWM]]
