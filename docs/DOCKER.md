# Entorno Docker — mismo repo en Windows, Linux o el servidor

## Por qué

El repo (código + `CLAUDE.md` + `.claude/`) es solo texto, corre en
cualquier sitio. Lo que varía entre tu Windows, tu portátil Linux y el
servidor es el runtime: versión de Node, si `claude`/`codex` están
instalados, PATH, etc. El contenedor fija eso una vez y lo monta igual en
los tres sitios.

## Requisitos por host

- **Windows**: Docker Desktop con backend WSL2. Clona el repo *dentro* del
  filesystem de WSL2 (no en `C:\Users\...`) para evitar problemas de
  permisos/rendimiento con bind mounts.
- **Linux (portátil o servidor)**: Docker Engine + el plugin `docker compose`
  (o `docker-compose` standalone).

## Primer arranque (una vez por host)

```bash
docker compose build
docker compose run --rm dev
```

Dentro del contenedor:

```bash
claude   # primera vez: te pide login, queda guardado en el volumen claude-config
codex login   # o la env var de API key — queda guardado en el volumen codex-config
```

Dentro de Claude Code, instala el plugin de Codex (solo la primera vez por
volumen `claude-config`; si ya lo instalaste antes en ese mismo host, se
salta este paso):

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

El login se guarda en los volúmenes nombrados (`claude-config`,
`codex-config`), no en la imagen ni en el repo — no se sube a git y
sobrevive a `docker compose down` (solo se pierde con `docker compose down -v`).

## Uso diario

```bash
docker compose run --rm dev
```

Te deja en una shell dentro de `/workspace` (= la raíz del repo montada
desde el host). Ahí dentro corres `claude` normalmente — todo lo definido
en `CLAUDE.md` y `.claude/` se aplica igual que si lo corrieras sin Docker.

## En el servidor (uso no interactivo / mantenerlo corriendo)

Si el servidor va a tener el contenedor levantado de forma persistente en
vez de entrar con `run --rm` cada vez:

```bash
docker compose up -d dev
docker compose exec dev bash
```

## Notas

- Los tres hosts (Windows, portátil, servidor) comparten `Dockerfile` y
  `docker-compose.yml` — no hay nada específico de plataforma que mantener
  a mano.
- Si cambias la lista de dependencias del `Dockerfile` (versión de Node,
  paquetes), hay que `docker compose build` de nuevo en cada host antes del
  siguiente `run`.
- Las credenciales de cada host quedan en su propio volumen local — hacer
  login en el portátil no te loguea en el servidor, es intencional.
