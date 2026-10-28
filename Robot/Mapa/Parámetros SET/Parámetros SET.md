---
tags: [indice]
---
# Parámetros SET

Campos que acepta `SET <campo> <valor>` en modo desarrollador. Los atiende [[saveDeveloperValue]]; los perfiles se guardan en la NVS como `motionV2` y `turnV1`.

| campo | defecto | rango |
| --- | --- | --- |
| [[SET accel]] | `350` | `10..1000` |
| [[SET active]] | `85` | `0..180 (entero)` |
| [[SET decel]] | `400` | `10..1000` |
| [[SET device]] | `Atta-V-02` | `texto de 1..31 caracteres, sin comas` |
| [[SET filterms]] | `50` | `0..200` |
| [[SET forward]] | `170` | `0..180 (entero)` |
| [[SET inactive]] | `50` | `0..180 (entero)` |
| [[SET kd]] | `0` | `0..10` |
| [[SET ki]] | `0.8` | `0..100` |
| [[SET kp]] | `2` | `0..100` |
| [[SET lfff]] | `0` | `0..10` |
| [[SET lfhold]] | `0` | `0..start (60)` |
| [[SET lfstart]] | `60` | `0..maxPWM (230)` |
| [[SET lkd]] | `0` | `0..10` |
| [[SET lki]] | `0.8` | `0..100` |
| [[SET lkp]] | `2` | `0..100` |
| [[SET lppr]] | `820` | `1..100000` |
| [[SET lradius]] | `22` | `5..100` |
| [[SET lrff]] | `0` | `0..10` |
| [[SET lrhold]] | `0` | `0..start (60)` |
| [[SET lrstart]] | `60` | `0..maxPWM (230)` |
| [[SET maxpwm]] | `230` | `1..255` |
| [[SET neutral]] | `75` | `0..180 (entero)` |
| [[SET pwmhz]] | `20000` | `200..30000 (entero)` |
| [[SET reverse]] | `135` | `0..180 (entero)` |
| [[SET rfff]] | `0` | `0..10` |
| [[SET rfhold]] | `0` | `0..start (60)` |
| [[SET rfstart]] | `60` | `0..maxPWM (230)` |
| [[SET rkd]] | `0` | `0..10` |
| [[SET rki]] | `0.8` | `0..100` |
| [[SET rkp]] | `2` | `0..100` |
| [[SET rppr]] | `820` | `1..100000` |
| [[SET rradius]] | `22` | `5..100` |
| [[SET rrff]] | `0` | `0..10` |
| [[SET rrhold]] | `0` | `0..start (60)` |
| [[SET rrstart]] | `60` | `0..maxPWM (230)` |
| [[SET speed]] | `150` | `10..300` |
| [[SET stallms]] | `1500` | `300..5000` |
| [[SET startms]] | `200` | `0..500 (menor que stallMs)` |
| [[SET stop]] | `145` | `0..180 (entero)` |
| [[SET sync]] | `1` | `0..10` |
| [[SET tolerance]] | `0.5` | `0.1..5` |
| [[SET track]] | `120` | `40..400` |
| [[SET turnaccel]] | `120` | `10..1000` |
| [[SET turnapproach]] | `40` | `5..100` |
| [[SET turndecel]] | `120` | `10..1000` |
| [[SET turnspeed]] | `120` | `10..300` |
| [[SET turnzone]] | `5` | `1..100` |
