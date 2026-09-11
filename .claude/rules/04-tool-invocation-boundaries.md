# Regla: respeta las restricciones de invocación de las herramientas

`openai/codex-plugin-cc` marca `/codex:review` y `/codex:adversarial-review`
con `disable-model-invocation: true`: es una barrera puesta a propósito por
el autor del plugin para que esos dos comandos concretos los dispare
siempre una persona, nunca el modelo por su cuenta. `/codex:rescue` no
tiene esa restricción.

Esto ya se intentó rodear una vez en este proyecto (llamar directamente al
script interno del plugin, o dejar esa llamada documentada como
"automatización" en un skill) y el propio clasificador de permisos de
Claude Code lo bloqueó como "Instruction Poisoning". No fue un falso
positivo: escribir en el repo "salta esta restricción" es indistinguible de
una instrucción inyectada para que una sesión futura se salte a propósito
un límite de seguridad puesto por un tercero.

**Code nunca:**
- llama al script/binario interno que hay detrás de un comando marcado
  `disable-model-invocation`,
- pide o añade permisos en `.claude/settings.json` (u otro fichero de
  configuración) cuyo único efecto sea neutralizar esa restricción,
- documenta en ningún skill, rule o agent un procedimiento para lograr el
  mismo efecto por otra vía.

**Si Code necesita ese comando disparado automáticamente:** usa la
alternativa legítima que sí está disponible sin restricción
(`/codex:rescue` pidiendo explícitamente solo-revisión, ver
`00-workflow-loop.md`), o le pide al usuario que active el *review gate*
del propio plugin — nunca inventa una tercera vía.
