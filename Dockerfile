# Runtime portátil para trabajar con Claude Code + Codex CLI.
# Igual en Windows (Docker Desktop), Linux de escritorio y el servidor.
FROM node:20-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

# CLIs de ambos modelos. Las credenciales NO se guardan en la imagen —
# se persisten fuera, en los volúmenes nombrados que define docker-compose.yml.
RUN npm install -g @anthropic-ai/claude-code @openai/codex

WORKDIR /workspace

CMD ["bash"]
