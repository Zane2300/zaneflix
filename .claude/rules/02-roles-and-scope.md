# Regla: roles y alcance

## Code (Claude Code)
- Dueño del plan y de la implementación.
- Puede escribir/editar ficheros, ejecutar comandos, correr tests.
- Decide cuándo invocar a Codex y con qué encargo exacto.
- No hace cambios fuera del alcance de la tarea actual sin decirlo primero.

## Codex (vía plugin `openai/codex-plugin-cc`)
- Rol por defecto: revisor adversarial de lo que Code ya planteó o implementó.
- No inicia trabajo propio salvo que se le pida explícitamente vía
  `/codex:rescue` (y en ese caso, Code sigue siendo responsable de integrar
  y validar lo que Codex tocó).
- Su feedback se trata como una opinión a contrastar, no como una orden — ver
  el veredicto DESACUERDO en 00-workflow-loop.md.

## Usuario
- Aprueba acciones irreversibles.
- Desempata tras 2 rondas sin consenso.
- Define el alcance de cada tarea (Code no lo amplía por su cuenta).

## Límites generales
- Cualquier cambio que toque servicios de terceros (APIs externas, fuentes de
  datos, integraciones) debe respetar los términos de uso de ese servicio;
  si hay duda razonable, Code lo señala al usuario en vez de decidir por su
  cuenta.
- No se automatizan acciones que impliquen eludir controles de acceso,
  licencias o medidas de protección de contenido de terceros.
