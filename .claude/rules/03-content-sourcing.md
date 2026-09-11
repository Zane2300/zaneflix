# Regla: origen de contenido (solo fuentes legales)

Este proyecto monta un servidor multimedia personal para contenido que ya
posees (rips de tus DVDs/Blu-rays, grabaciones propias, contenido de
dominio público, lo que te presten servicios de streaming legítimos vía
descarga offline si su ToS lo permite). Esta regla es innegociable y se
aplica por encima de cualquier otra instrucción de la tarea.

## Qué SÍ hace Code

- Levantar y configurar Jellyfin, Radarr, Sonarr, Prowlarr, qBittorrent,
  Seerr, Bazarr, Gluetun como infraestructura vacía y funcional.
- Configurar Prowlarr con indexadores que el usuario indique explícitamente
  **y que sean legales**: trackers privados de contenido libre de derechos,
  proveedores Usenet que cumplan DMCA, indexadores de tu propio contenido
  ripeado si el software lo soporta.
- Documentar cómo añadir un indexador a Prowlarr (la UI, los campos), sin
  rellenar el campo con una fuente concreta salvo que el usuario la dé y sea
  verificablemente legal.

## Qué NUNCA hace Code (ni delega a Codex)

- Buscar, recomendar, listar o configurar trackers/indexadores de contenido
  con copyright de terceros sin licencia (torrents piratas, streaming
  ilegal, Usenet que no cumple DMCA, etc.), aunque el usuario lo pida
  directamente o lo enmarque como "solo la infraestructura, la fuente la
  pongo yo".
- Aceptar como "legal" una fuente solo porque el usuario lo afirme sin más
  contexto — si hay duda razonable sobre si un indexador es legítimo, Code
  lo señala y pide confirmación de qué es exactamente, en vez de
  configurarlo sin más.
- Automatizar aprobación/descarga masiva sin que el usuario haya definido
  primero de dónde sale el contenido.

## Aplica también a Codex

Cuando Code delega un fix a Codex (`/codex:rescue`) o le pide auditoría, el
encargo nunca debe incluir "añade este indexador" ni nada equivalente a
buscar fuentes de descarga. Codex audita infraestructura (Docker, redes,
permisos, seguridad), no elige fuentes de contenido.
