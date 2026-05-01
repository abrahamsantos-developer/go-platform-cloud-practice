# Igual a 02_multistage, pero acompañado de un `.dockerignore` en el repo
# root que excluye archivos que nunca deberían entrar al contexto del build.
#
# El `.dockerignore` actúa ANTES del `COPY`: archivos listados ahí no se
# envían al daemon de Docker, ni siquiera quedan disponibles para
# un `COPY .` accidental.
#
# Por qué importa:
#   - Evita filtrar `.env`, `node_modules`, `.git`, secrets, etc.
#   - Reduce el contexto que Docker envía al daemon (build más rápido).
#   - Bloquea el "COPY accidental" de archivos generados.
#
# Construir desde el REPO ROOT:
#   docker build -f 01-docker/03_dockerignore/Dockerfile -t goose:dockerignore .
#
# Probá quitando el `.dockerignore` del repo root y mirá cuánto cambia el
# tamaño del contexto: la primera línea del build dice
#   "transferring context: X MB"

FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY service/go.mod ./
RUN go mod download

COPY service/ ./

RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \
    -o /server .

# Imagen final
FROM scratch
COPY --from=builder /server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
