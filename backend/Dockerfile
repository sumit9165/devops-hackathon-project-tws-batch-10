# syntax=docker/dockerfile:1.7

########################################
# Stage 1: Dependencies
########################################
FROM golang:1.22-alpine AS deps

WORKDIR /src

# Install minimal required packages
RUN apk add --no-cache git=2.45.2-r0 ca-certificates=20240226-r0

# Copy dependency manifests first
COPY go.mod ./

# Cache Go modules
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

########################################
# Stage 2: Build
########################################
FROM golang:1.22-alpine AS builder

WORKDIR /src

# Build env
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Copy Go module cache
#COPY --from=deps /go/pkg/mod /go/pkg/mod

# Copy source code
COPY . .

# Build with cache mounts
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go build \
      -trimpath \
      -buildvcs=false \
      -ldflags="-s -w -buildid=" \
      -o /app/skillpulse .

########################################
# Stage 3: Runtime
########################################
FROM gcr.io/distroless/static-debian12:nonroot

# App directory
WORKDIR /app

# Copy binary only
COPY --from=builder /app/skillpulse /app/skillpulse

# Non-root runtime
USER nonroot:nonroot

# Runtime env
ENV GIN_MODE=release

# Application port
EXPOSE 5100

# Graceful shutdown support
STOPSIGNAL SIGTERM

# Run application
ENTRYPOINT ["/app/skillpulse"]
