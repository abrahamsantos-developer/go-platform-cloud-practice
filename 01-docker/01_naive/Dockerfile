# ANTI-PATRÓN — NO usar en producción.
#
# Imagen monolítica: el toolchain de Go + libs de build + el código fuente +
# el binario, todo en la misma capa final. Resultado: ~1GB de imagen para
# correr un binario de ~10MB.
#
# Problemas:
#   - Pull lento en CI y en cada nodo del cluster.
#   - Imagen contiene compilador, fuentes y deps de build → mayor superficie
#     de ataque (si un atacante entra al pod tiene `go`, `git`, `apk`, etc.).
#   - Cache de layers se rompe ante cualquier cambio en el código.
#
# Construir desde el REPO ROOT:
#   docker build -f 01-docker/01_naive/Dockerfile -t goose:naive .
#
# Verificar tamaño:
#   docker images goose:naive

FROM golang:1.26-bookworm

WORKDIR /app

# Copiamos TODO el contexto de una vez. Mal: si cambia un archivo,
# Docker invalida desde acá hacia abajo.
COPY service/ .

RUN go mod download
RUN go build -o /server .

EXPOSE 8080
ENTRYPOINT ["/server"]
