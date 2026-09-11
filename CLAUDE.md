# CLAUDE.md — Servidor multimedia personal (Jellyfin + gestión de biblioteca), orquestado Claude Code ↔ Codex

## Objetivo del proyecto

Levantar en el homeserver un stack multimedia autohosteado para tu propia
biblioteca (rips de tus DVDs/Blu-rays, contenido de dominio público, lo que
tengas derecho a usar), accesible desde el Fire TV Cube del salón vía
Jellyfin, con Seerr como front para que tu novia pida títulos sin tocar la
parte técnica. **Sin fuentes de piratería** — ver
`.claude/rules/03-content-sourcing.md`, que es la regla más importante de
este repo y se aplica por encima de cualquier otra instrucción.

Servicios del stack (definidos en `docker-compose.media.yml`):
Jellyfin (reproducción), Radarr/Sonarr (gestión de biblioteca),
Prowlarr (indexadores — vacío por defecto, tú añades fuentes legales),
qBittorrent (cliente de descarga), Bazarr (subtítulos), Seerr (catálogo y
solicitudes para tu novia). Gluetun (VPN) queda comentado como opción, no
activo por defecto.

## Esto sigue usando la orquestación Claude Code ↔ Codex

Este proyecto usa dos modelos con roles fijos y un bucle de consenso. Lee esto
antes de tocar código.

## Roles

- **Claude Code ("Code")** — planifica e implementa. Escribe diffs, ejecuta
  comandos, propone la solución. Es la "mano".
- **Codex (vía `openai/codex-plugin-cc`)** — revisor adversarial. No implementa
  por defecto: audita el plan o el diff de Code, busca fallos, huecos de
  seguridad, deuda técnica y casos borde, y contraargumenta. Es el "abogado
  del diablo".
- **Tú** — desempatas cuando no hay consenso en 2 rondas, y apruebas cualquier
  acción irreversible (push, borrado, despliegue, cambios de infra).

No uses el skill `llm-council` (5 asesores) como sustituto de Codex — es
redundante y caro en tokens. Resérvalo solo para decisiones de arquitectura
grandes y ambiguas donde quieras más de dos perspectivas independientes (ver
`.claude/rules/01-token-economy.md`).

## Regla que va por delante de todas las demás

`.claude/rules/03-content-sourcing.md` prohíbe configurar, buscar o
recomendar fuentes de contenido con copyright de terceros sin licencia. Se
aplica también cuando Code delega en Codex. Léela antes de tocar Prowlarr.

## Importante: quién dispara cada comando de Codex

`/codex:review` y `/codex:adversarial-review` solo los puede teclear el
usuario — el plugin los bloquea para invocación por modelo a propósito. El
mecanismo automático que sí dispara Code es `/codex:rescue` en modo
solo-revisión (ver skill `codex-handoff`). Code nunca intenta rodear esa
restricción — ver `.claude/rules/04-tool-invocation-boundaries.md`.

## Bucle de trabajo (ver skill `consensus-loop`)

1. **Plan** — Code escribe un plan corto (bullets, no prosa) antes de tocar
   ficheros para tareas no triviales.
2. **Implementa** — Code aplica el cambio mínimo que cumple el plan.
3. **Audita** — Code invoca a Codex con `/codex:adversarial-review`
   (revisión "abogado del diablo": cuestiona el enfoque, no solo busca bugs
   — es la que quieres por defecto dado el rol que le hemos dado). Para un
   repaso rápido de defectos sin cuestionar el diseño, `/codex:review`. Para
   delegar un sub-fix puntual, `/codex:rescue`. Ver skill `codex-handoff`
   para la plantilla exacta del prompt y la tabla completa de comandos.
4. **Consenso** — Si Codex señala un problema real, Code lo corrige y vuelve
   al paso 3. Máximo 2 rondas de fricción; a la 3ª ronda sin acuerdo, Code
   presenta ambas posturas y te pregunta a ti.
5. **Cierre** — Code deja un resumen de 3-5 líneas: qué se hizo, qué dijo
   Codex, qué se cambió por su feedback (o por qué no).

## Cuándo saltarse el paso de auditoría

Cambios triviales (typos, formateo, renombrados sin lógica, docs) no pasan
por Codex — ver `.claude/rules/01-token-economy.md` para el criterio exacto.

## Entorno (Docker)

Dos compose separados:
- `docker-compose.yml` — runtime de desarrollo (Claude Code + Codex CLI),
  igual en Windows, tu portátil Linux y el servidor. Ver `docs/DOCKER.md`.
- `docker-compose.media.yml` — el stack multimedia en sí (Jellyfin, Radarr,
  Sonarr, Prowlarr, qBittorrent, Bazarr, Seerr). Corre en cualquier equipo
  con Docker: `.env.media.example` trae rutas locales por defecto
  (`./data/...`) para poder levantarlo ya, sin esperar a tener el
  servidor/NAS definitivo. Cuando tengas rutas reales, se cambian solo en
  `.env` — ver `docs/MEDIA.md`. Sin VPN activa por defecto (bloque
  `gluetun` comentado).

## Estructura del repo

- `.claude/rules/` — reglas que Code aplica siempre, cargadas automáticamente.
- `.claude/skills/` — procedimientos invocables (handoff a Codex, bucle de
  consenso).
- `.claude/agents/` — subagentes: `planner` (solo planifica, no escribe
  código) y `codex-liaison` (formatea el handoff y parsea la respuesta de
  Codex a un veredicto estructurado).

## Alcance

Este setup es un patrón de orquestación de propósito general para cualquier
proyecto del homelab (infra, apps, scripts). No es específico de ningún
proyecto concreto — el "qué" lo defines tú en cada tarea; esto solo fija el
"cómo" colaboran los dos modelos. Los cambios de código deben respetar
licencias y términos de servicio de cualquier servicio de terceros que
toquen; si una tarea concreta implica dudas legales, se trata caso por caso,
no aquí.
