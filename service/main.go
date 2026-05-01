// Package main - "the goose service".
//
// Minimal HTTP service that we carry through the whole platform/cloud stack.
// Pure stdlib - zero external dependencies to get started.
//
// Endpoints:
//
//	GET  /healthz   -> liveness/readiness probe
//	GET  /count     -> current counter value
//	POST /count     -> increment counter
//
// Environment variables:
//
//	PORT            (default: 8080)
//	READY_DELAY_MS  (default: 0)  <- simulates slow warmup, useful for module 03
//	DB_HOST         optional host to TCP dial once at startup
//	DB_PORT         optional port to TCP dial once at startup
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"sync/atomic"
	"syscall"
	"time"
)

// ready flips to true after READY_DELAY_MS, simulating warmup
// (for example: a DB connection pool initializing).
var ready atomic.Bool

// counter - module 01 only needs an atomic counter.
var counter atomic.Int64

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

	port := envOrDefault("PORT", "8080")
	readyDelay := envInt("READY_DELAY_MS", 0)
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")

	logDBReachability(logger, dbHost, dbPort)

	// Simulate warmup in the background.
	go func() {
		if readyDelay > 0 {
			logger.Info("warming up", "delay_ms", readyDelay)
			time.Sleep(time.Duration(readyDelay) * time.Millisecond)
		}
		ready.Store(true)
		logger.Info("ready")
	}()

	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", handleHealthz(logger))
	mux.HandleFunc("GET /count", handleGetCount)
	mux.HandleFunc("POST /count", handleIncCount)

	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	// Graceful shutdown - classic Kubernetes interview topic.
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	go func() {
		logger.Info("server starting", "port", port)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("server failed", "err", err)
			os.Exit(1)
		}
	}()

	<-ctx.Done()
	logger.Info("shutdown requested")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		logger.Error("shutdown failed", "err", err)
	}
	logger.Info("bye")
}

func logDBReachability(logger *slog.Logger, host, port string) {
	if host == "" || port == "" {
		logger.Info("db reachability check skipped", "reason", "DB_HOST or DB_PORT not set")
		return
	}

	address := net.JoinHostPort(host, port)
	conn, err := net.DialTimeout("tcp", address, 1500*time.Millisecond)
	if err != nil {
		logger.Warn("db reachability check failed", "address", address, "err", err)
		return
	}
	_ = conn.Close()
	logger.Info("db reachability check succeeded", "address", address)
}

func handleHealthz(logger *slog.Logger) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if !ready.Load() {
			w.WriteHeader(http.StatusServiceUnavailable)
			_ = json.NewEncoder(w).Encode(map[string]string{"status": "warming up"})
			return
		}
		_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	}
}

func handleGetCount(w http.ResponseWriter, r *http.Request) {
	_ = json.NewEncoder(w).Encode(map[string]int64{"count": counter.Load()})
}

func handleIncCount(w http.ResponseWriter, r *http.Request) {
	n := counter.Add(1)
	_ = json.NewEncoder(w).Encode(map[string]int64{"count": n})
}

func envOrDefault(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func envInt(key string, def int) int {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		fmt.Fprintf(os.Stderr, "warning: invalid %s=%q, using default %d\n", key, v, def)
		return def
	}
	return n
}
