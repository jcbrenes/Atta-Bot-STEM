---
tags: [mensaje]
---
# Mensaje T

Fila CSV de telemetría que se activa con `TELEMETRY ON` y se imprime cada 100 ms. La guarda [[capturar_movimiento.main]] en un CSV.

## Lo emiten
- [[emitTelemetry]]

## Literales
- `T,%lu,%s,%s,%d,%.4f,%lu,%lu,%.3f,%.3f,%.2f,%.2f,%.2f,%.2f,%d,%d,%.3f,%.3f,%d,%d,%s\n`

## Columnas
1. `record`
2. `ms`
3. `device`
4. `mode`
5. `reverse`
6. `dt_s`
7. `right_ticks`
8. `left_ticks`
9. `right_mm`
10. `left_mm`
11. `right_ref`
12. `left_ref`
13. `right_speed`
14. `left_speed`
15. `right_pwm`
16. `left_pwm`
17. `right_integral`
18. `left_integral`
19. `right_saturated`
20. `left_saturated`
21. `fault`
