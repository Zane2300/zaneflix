# Regla: economía de tokens

El objetivo de usar dos modelos es mejorar el resultado, no duplicar gasto.
Por defecto, prioriza recortar tokens sin perder información decisiva.

## Cuándo saltarte la auditoría de Codex

No dispares `/codex:review` ni `/codex:rescue` para:
- typos, formateo, renombrados sin cambio de lógica, actualización de docs,
- cambios de una sola línea con impacto obvio y local,
- reversión de un cambio que el propio Codex ya validó antes.

Para todo lo demás (lógica nueva, cambios de esquema/API, infra, seguridad,
concurrencia), pasa por el bucle completo.

## Formato de las respuestas de Code

- Planes: bullets, no prosa.
- Resúmenes de cierre: 3-5 líneas, sin repetir el diff completo.
- Nunca pegues el diff entero en el mensaje al usuario si ya está en el
  workspace — enlaza al fichero/línea.
- Al invocar Codex, manda solo el contexto que Codex no puede inferir del
  propio diff (intención, restricciones, qué NO quieres que cambie). No le
  reenvíes el CLAUDE.md completo ni el historial de la conversación.

## Modelo/esfuerzo de Codex

`.codex/config.toml` en la raíz fija `model_reasoning_effort = "medium"` por
defecto para todo lo que se lance desde este repo (solo aplica si el
directorio está marcado como trusted en Codex). Para una pasada barata y
rápida en un sub-fix concreto, usa `/codex:rescue --model spark <encargo>`
(el plugin lo mapea a un modelo pequeño); para algo que merece más cuidado,
sube el esfuerzo puntualmente con `--effort high` en esa llamada, no
cambiando el default del repo.

## `llm-council` vs Codex

`llm-council` lanza 5 asesores + síntesis: mucho más caro que un solo
`/codex:review`. Solo lo usas cuando:
- la decisión es de arquitectura (no de implementación) y de alto impacto,
- hay ambigüedad genuina donde dos perspectivas (Code + Codex) no bastan,
- el propio usuario lo pide explícitamente.

Para el día a día de implementar y revisar código, Codex ya cubre el rol de
"segunda opinión" — no dupliques con el council.
