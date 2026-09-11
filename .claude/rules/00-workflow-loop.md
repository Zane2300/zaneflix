# Regla: bucle plan → implementa → audita → consenso

Aplica a cualquier tarea que no sea trivial (ver 01-token-economy.md para el
umbral).

1. Antes de escribir código, Code publica un plan de 3-8 bullets: qué
   ficheros toca, qué enfoque usa, qué alternativas descartó y por qué.
2. Code implementa el cambio más pequeño que cumple el plan. Nada de
   refactors oportunistas no pedidos.
3. Code dispara la auditoría de Codex (skill `codex-handoff`) — **Code no
   puede ejecutar `/codex:review` ni `/codex:adversarial-review` por su
   cuenta: el plugin los marca `disable-model-invocation: true` a propósito,
   solo los dispara una persona escribiéndolos.** Por eso el mecanismo
   automático por defecto es otro:
   - Por defecto → `/codex:rescue` con un encargo explícito de solo-revisión
     ("revisa esto en modo adversarial: cuestiona el enfoque, asunciones y
     trade-offs; NO edites ningún fichero, solo informa"). Code sí puede
     disparar esto sin pedirte permiso cada vez.
   - Si tú quieres correr la revisión "oficial" del plugin (mejor prompt
     curado, solo-lectura garantizado por el propio comando, no por
     instrucción) → tecleas tú `/codex:adversarial-review` o `/codex:review`
     cuando quieras.
   - Automatización total sin que nadie teclee nada → activar el *review
     gate* del plugin (`/codex:setup --enable-review-gate`), decisión tuya,
     no activada por defecto (ver `01-token-economy.md`).
   - Trabajo en background mientras Code continúa → añade `--background` a
     `/codex:rescue` y recupera con `/codex:result`.
4. Code clasifica la respuesta de Codex en uno de tres veredictos:
   - **OK** — sin objeciones de peso → cierre.
   - **AJUSTAR** — Codex señala algo concreto y corregible → Code aplica el
     fix, vuelve al paso 3 (ronda 2).
   - **DESACUERDO** — Code cree que la objeción de Codex es incorrecta o
     fuera de alcance → Code responde con su contraargumento en el mismo
     hilo de Codex (no reinicia desde cero).
5. Límite: 2 rondas de fricción por tarea. Si tras la ronda 2 sigue sin haber
   consenso, Code para y presenta ambas posturas al usuario en 4-6 líneas,
   sin ejecutar nada más hasta recibir instrucción.
6. Ninguna acción irreversible (push a remoto, borrado, despliegue, cambios
   de infra que afecten a otros servicios) se ejecuta sin aprobación
   explícita del usuario, aunque Code y Codex ya estén de acuerdo.
