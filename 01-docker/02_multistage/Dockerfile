# PATRÓN CORRECTO — multi-stage build.
#
# Stage 1 (builder): imagen pesada con toolchain de Go.
# Stage 2 (final):   `scratch` (0 bytes) + el binario estático.
#
# Resultado: ~10MB. Sin shell, sin compilador, sin nada que no sea tu binario.
#
# Construir desde el REPO ROOT:
#   docker build -f 01-docker/02_multistage/Dockerfile -t goose:multi .
#
# Verificar tamaño:
#   docker images goose:multi

# ============================================================
# STAGE 1 — builder
# ============================================================
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Copiamos go.mod/go.sum primero. Esta capa solo se invalida si cambian
# las deps. El `go mod download` queda cacheado entre builds.
COPY service/go.mod ./
# COPY service/go.sum ./   # cuando agreguemos deps reales (módulo 02)
RUN go mod download

# Ahora sí copiamos el código. Cambios de código NO invalidan la capa
# de `go mod download` de arriba.
COPY service/ ./

# CGO_ENABLED=0 → binario estático, sin libc → corre en scratch.
# GOOS=linux    → forzamos target Linux (importante en builds desde mac).
# -ldflags "-s -w" → strip symbols + debug info → binario más chico.
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \
    -o /server .

# ============================================================
# STAGE 2 — final
# ============================================================
FROM scratch

# Solo copiamos el binario. Nada más.
COPY --from=builder /server /server

EXPOSE 8080
ENTRYPOINT ["/server"]
