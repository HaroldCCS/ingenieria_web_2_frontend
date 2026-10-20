# syntax=docker/dockerfile:1
# =====================================================================
# UMB Planifica Web - imagen multi-etapa (Ejercicio 3 del caso de estudio)
#   build   -> Node 22 + pnpm compilan la SPA (Vite) a /app/dist
#   runtime -> Nginx sin privilegios sirve dist/ y reenvía /api a la API
# La imagen final NO contiene Node, node_modules ni el código fuente.
# =====================================================================

# ---------- Etapa 1: compilación ----------
FROM node:22-alpine AS build
WORKDIR /app
# pnpm en la versión exacta de "packageManager" (package.json) vía corepack
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable
# Dependencias primero: esta capa se reutiliza mientras no cambie el lockfile
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm-store,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile
COPY . .
# Las variables VITE_* quedan incrustadas en el JavaScript público: NUNCA un secreto.
# Vacía = rutas relativas (/api/v1/...) servidas por el mismo Nginx.
ARG VITE_API_BASE_URL=""
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
RUN pnpm build

# ---------- Etapa 2: servidor estático ----------
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
LABEL org.opencontainers.image.title="umb-planifica-web" \
      org.opencontainers.image.description="Frontend React de UMB Planifica servido por Nginx"
# Destino del proxy /api (se puede sobrescribir al ejecutar)
ENV API_UPSTREAM=http://api:8000
# --chmod: el usuario nginx (no root) debe poder leer la plantilla aunque en el anfitrión
# sea 600. Ojo: el modo también se aplica a la carpeta templates/ que crea el COPY, por eso
# es 0755 (con 0644 la carpeta queda sin permiso de ejecución y Nginx no puede entrar).
COPY --chmod=0755 nginx.conf /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
# CMD heredado de la imagen base: nginx -g 'daemon off;' (forma exec, usuario nginx UID 101)
