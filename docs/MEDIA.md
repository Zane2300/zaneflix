# Stack multimedia — arranque en cualquier equipo

Este documento es sobre `docker-compose.media.yml` (Jellyfin + gestión de
biblioteca). Para el runtime de desarrollo (Claude Code + Codex CLI), ver
`docs/DOCKER.md` — son dos compose independientes, no se levantan juntos.

## Arranque rápido (sin rutas reales todavía)

**Linux (host nativo o servidor):** Docker crea `./data/*` solo si no
existen, pero como `root:root` — los contenedores corren con `PUID`/`PGID`
(por defecto 1000:1000) y no podrán escribir ahí sin este paso previo:

```bash
cp .env.media.example .env
mkdir -p data/config data/media data/downloads
sudo chown -R 1000:1000 data/   # o el PUID:PGID que hayas puesto en .env
docker compose -f docker-compose.media.yml up -d
```

Sin esto, Radarr/Sonarr no podrán importar y qBittorrent no podrá guardar
descargas (fallan en silencio o con error de permisos dentro del
contenedor). Si no lo has hecho y algo falla al primer arranque, es lo
primero a revisar.

**Windows/Mac (Docker Desktop):** no hace falta el `chown` — Docker Desktop
traduce los permisos del volumen compartido y `PUID`/`PGID` no mapea a un
usuario real del host. Solo:

```bash
cp .env.media.example .env
docker compose -f docker-compose.media.yml up -d
```

Requiere Docker Desktop en modo contenedores Linux (el modo por defecto) y
que la carpeta del repo esté dentro de lo que Docker Desktop puede compartir
(en Windows, evita rutas fuera del filesystem de WSL2 si usas ese backend).

En ambos casos, "cualquier equipo" significa **Docker local** (el propio
Compose corriendo contra el motor de esa misma máquina) — las rutas
relativas de `.env.media.example` no se resuelven si apuntas Compose a un
Docker remoto (`DOCKER_HOST`/`docker context`).

Estas carpetas locales están en `.gitignore`: no se suben a git y no son la
biblioteca real, solo un banco de pruebas.

## Servicios y puertos

| Servicio | UI | Rol |
|---|---|---|
| Jellyfin | http://localhost:8096 | Reproducción |
| Radarr | http://localhost:7878 | Gestión de películas |
| Sonarr | http://localhost:8989 | Gestión de series |
| Prowlarr | http://localhost:9696 | Indexadores (vacío por defecto) |
| Bazarr | http://localhost:6767 | Subtítulos |
| Seerr | http://localhost:5055 | Catálogo/solicitudes |
| qBittorrent | http://localhost:8080 | Cliente de descarga |

## Cuando tengas las rutas reales del servidor

Edita `.env` (no `.env.media.example`) y cambia `MEDIA_ROOT`,
`DOWNLOADS_ROOT`, `CONFIG_ROOT` por rutas absolutas del host (p. ej. un
disco montado en `/mnt/biblioteca`), ajusta `PUID`/`PGID` al usuario real
del servidor (`id -u` / `id -g`), y relanza:

```bash
docker compose -f docker-compose.media.yml up -d
```

**Requisito, no opcional:** `MEDIA_ROOT` y `DOWNLOADS_ROOT` deben vivir en
el mismo filesystem del host (mismo disco/share). Con los defaults locales
esto se cumple solo porque `data/media` y `data/downloads` son hermanos.
Si al migrar los apuntas a discos/shares distintos, Radarr/Sonarr pierden la
capacidad de mover lo descargado a la biblioteca por hardlink/rename
atómico y caen a copiar+borrar: más lento y con doble espacio ocupado
mientras dura la copia.

No hace falta tocar `docker-compose.media.yml` — solo el `.env`. Si vienes
de las rutas locales de prueba, la config de cada servicio (guardada bajo
`CONFIG_ROOT`) no se migra sola: si quieres conservarla, copia el contenido
del `CONFIG_ROOT` viejo al nuevo antes de relanzar; si no, cada servicio
vuelve a pedir configuración inicial.

## Indexadores en Prowlarr

Prowlarr arranca sin ningún indexador configurado. Se añaden a mano desde
su UI, y deben ser fuentes legales — ver
`.claude/rules/03-content-sourcing.md` (regla que va por delante de
cualquier otra instrucción en este repo).

## VPN (Gluetun)

No activa por defecto. El bloque `gluetun` en `docker-compose.media.yml`
está comentado como referencia para cuando decidas enrutar qBittorrent por
VPN — requiere descomentarlo, rellenar el proveedor y las credenciales
(nunca hardcodeadas, vía `.env`), y decisión explícita tuya antes de
activarlo (ver `.claude/rules/00-workflow-loop.md`, cambios de infra
necesitan tu aprobación).
