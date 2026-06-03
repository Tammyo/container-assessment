# Stage 1: Build
FROM golang:1.25-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY Server/MuchToDo/go.mod Server/MuchToDo/go.sum ./
RUN go mod download

COPY Server/MuchToDo/ .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/api/...

# Stage 2: Run
FROM alpine:3.18

WORKDIR /app

RUN apk --no-cache add ca-certificates

RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

COPY --from=builder /app/main .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["./main"]
