---
name: codex-handoff
description: Cómo y cuándo Code entrega trabajo a Codex (openai/codex-plugin-cc) para revisión adversarial o delegación, qué comandos puede disparar Code por su cuenta y cuáles requieren que el usuario los teclee, y cómo formatear el encargo para minimizar tokens.
---

# Skill: codex-handoff

## Quién puede disparar cada comando

`/codex:review` y `/codex:adversarial-review` llevan
`disable-model-invocation: true` en el propio plugin: **solo el usuario
puede dispararlos, tecleándolos él.** Code no puede ejecutarlos por su
cuenta ni debe buscar otra vía para lograr el mismo efecto — ver
`.claude/rules/04-tool-invocation-boundaries.md`. `/codex:rescue` no tiene
esta restricción: Code sí puede dispararlo sin pedir permiso cada vez.

## Comandos disponibles (plugin `openai/codex-plugin-cc`)

| Comando | Quién lo dispara | Uso |
|---|---|---|
| `/codex:setup` | Usuario o Code | Comprueba que Codex CLI está listo (login con cuenta ChatGPT o API key). |
| `/codex:adversarial-review` | **Solo el usuario** | Revisión "abogado del diablo": cuestiona el enfoque elegido, las asunciones y los trade-offs — no solo busca defectos. Steerable (acepta texto de foco tras los flags). Solo lectura. Soporta `--base <ref>`, `--wait`, `--background`. |
| `/codex:review` | **Solo el usuario** | Revisión de solo lectura centrada en defectos (bugs, no diseño). Soporta `--base <ref>`, `--wait`, `--background`. |
| `/codex:rescue "<encargo>"` | Usuario o Code | Codex interviene en el workspace (puede editar ficheros, salvo que el encargo le pida explícitamente no hacerlo). Soporta `--background`, `--resume`, `--fresh`, `--model <nombre>` (p. ej. `spark` = modelo pequeño y barato), `--effort <nivel>`. Sin `--model`/`--effort`, usa los defaults de `.codex/config.toml`. |
| `/codex:result <job-id>` | Usuario o Code | Recupera el resultado de un job en background. |
| `/codex:status` | Usuario o Code | Lista jobs en curso. |
| `/codex:cancel <job-id>` | Usuario o Code | Cancela un job. |
| `/codex:transfer` | Usuario | Traspasa la sesión completa a Codex. |

## Auditoría automática por defecto: `/codex:rescue` en modo solo-revisión

Como Code no puede disparar `/codex:review`/`/codex:adversarial-review`,
el mecanismo automático del bucle (`00-workflow-loop.md`) es `/codex:rescue`
con un encargo que deja explícito que es solo revisión:

```
/codex:rescue revisa <alcance> en modo adversarial: cuestiona el enfoque,
las asunciones y los trade-offs elegidos, no solo busques bugs. NO edites
ningún fichero — devuelve solo tu análisis.
```

Esto no está garantizado como solo-lectura por el propio comando (a
diferencia de `/codex:review`/`adversarial-review`, que sí lo aplican a
nivel de plugin) — depende de que Codex respete la instrucción. Si quieres
la garantía real de solo-lectura y el prompt curado del plugin, teclea tú
`/codex:adversarial-review` cuando te venga bien.

## Automatización total: review gate (opcional, no activado por defecto)

El plugin soporta un "review gate": un hook que, cada vez que Code termina
de responder, dispara automáticamente `/codex:review`/`adversarial-review`
sobre lo que acaba de hacer y bloquea el cierre del turno hasta que Codex dé
el visto bueno. Es la vía oficial del plugin para automatización total sin
que nadie teclee nada — y sortea la restricción de invocación porque el
propio plugin es quien lo dispara, no el modelo.

- Activar: `/codex:setup --enable-review-gate`.
- Desactivar: `/codex:setup --disable-review-gate`.
- **No lo dejamos activado por defecto en este proyecto** (ver
  `01-token-economy.md`): puede generar bucles largos Code↔Codex que
  consumen cuota rápido si no estás vigilando la sesión. Actívalo tú mismo
  cuando quieras automatización total en una sesión concreta, y desactívalo
  al terminar.

## Plantilla de encargo a Codex

Cuando invoques cualquiera de los tres comandos, incluye solo esto (no el
CLAUDE.md completo, no el historial de chat):

```
Contexto: <1-2 líneas: qué problema resuelve este cambio>
Diff/alcance: <qué ficheros o rango de commits mirar>
Restricciones: <qué NO debe tocar o asumir>
Pregunta para Codex: <qué quieres que audite específicamente:
  seguridad / concurrencia / casos borde / rendimiento / diseño>
```

Esto reemplaza mandarle todo el contexto de la conversación — Codex ya ve el
código; solo necesita la intención y el foco de la revisión.

## Flujo recomendado

1. Cambios triviales → no invocar Codex (ver regla `01-token-economy.md`).
2. Cambios normales → Code dispara `/codex:rescue` en modo solo-revisión
   (ver plantilla arriba) tras implementar.
3. Cambios grandes/multi-fichero → añade `--background` y recupera con
   `/codex:result`.
4. Quieres la revisión "oficial" del plugin (mejor prompt, solo-lectura
   garantizado) → tú tecleas `/codex:review` o `/codex:adversarial-review`.
5. Sub-fix puntual que quieres delegar sin ocupar a Code → `/codex:rescue`
   normal (sin la restricción de no editar).

## Parseo del veredicto

Después de la respuesta de Codex, clasifícala tú mismo (Code) en OK /
AJUSTAR / DESACUERDO antes de responder al usuario — no le pegues el output
crudo de Codex al usuario salvo que lo pida.
