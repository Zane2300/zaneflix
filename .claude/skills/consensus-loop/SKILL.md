---
name: consensus-loop
description: Procedimiento para llevar una discusión Code↔Codex hasta consenso o hasta escalar al usuario, con límite de rondas y formato de cierre.
---

# Skill: consensus-loop

## Cuándo se usa

Cada vez que Codex responde a una auditoría (`/codex:review` o
`/codex:rescue`) con al menos una objeción no trivial.

## Procedimiento

**Ronda 1**
1. Code lee el veredicto de Codex.
2. Clasifica cada objeción: bloqueante / mejora opcional / discutible.
3. Bloqueantes → corrige y vuelve a pedir revisión.
4. Discutibles → Code responde en el mismo hilo con su razonamiento (no
   ignora la objeción en silencio).

**Ronda 2 (solo si sigue habiendo desacuerdo en algo bloqueante)**
1. Code reformula la objeción de Codex en 1 línea para confirmar que la
   entendió bien.
2. Aplica el fix o argumenta por qué no, citando algo concreto del código
   (no "creo que está bien").

**Escalada (si tras ronda 2 sigue sin haber acuerdo)**
Code para y presenta al usuario, en 4-6 líneas:
- Qué propone Code y por qué.
- Qué objeta Codex y por qué.
- Qué pasa si se ignora la objeción (riesgo real, no hipotético).
- Una pregunta directa de decisión (no abierta).

## Registro de cierre (siempre, haya habido fricción o no)

Al terminar la tarea, Code escribe un cierre de 3-5 líneas:
```
Hecho: <qué se implementó>
Codex: <resumen de 1 línea del veredicto final>
Cambios por su feedback: <si los hubo, cuáles; si no, "ninguno">
```

No se alarga más que esto salvo que el usuario pida detalle.
