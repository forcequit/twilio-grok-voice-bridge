#!/usr/bin/env bash
# Expose the local bridge so Twilio can reach /twiml-connect and wss://HOST/media-stream.
# Prefer a named / dashboard-managed tunnel (stable hostname). A Quick Tunnel is
# for testing only: the trycloudflare.com hostname changes every run, and you
# must update PUBLIC_HOST and restart the bridge.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
if [[ -f "${ROOT}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  . "${ROOT}/.env"
  set +a
fi

PORT="${PORT:-3000}"
BIN="${CLOUDFLARED_BIN:-cloudflared}"

if ! command -v "${BIN}" >/dev/null 2>&1; then
  echo "cloudflared not found. Install it from https://developers.cloudflare.com/tunnel/ or set CLOUDFLARED_BIN." >&2
  exit 1
fi

if [[ -n "${CLOUDFLARE_TUNNEL_TOKEN:-}" ]]; then
  exec "${BIN}" tunnel --no-autoupdate run --token "${CLOUDFLARE_TUNNEL_TOKEN}"
fi

if [[ -n "${CLOUDFLARED_CONFIG:-}" ]]; then
  exec "${BIN}" tunnel --no-autoupdate --config "${CLOUDFLARED_CONFIG}" run
fi

EXAMPLE="${ROOT}/cloudflared/config.example.yml"
if [[ -f "${ROOT}/cloudflared/config.yml" ]]; then
  exec "${BIN}" tunnel --no-autoupdate --config "${ROOT}/cloudflared/config.yml" run
fi

echo "No CLOUDFLARE_TUNNEL_TOKEN or CLOUDFLARED_CONFIG set."
echo "Starting a Quick Tunnel to http://127.0.0.1:${PORT} (hostname will change)."
echo "Copy the trycloudflare.com hostname into PUBLIC_HOST (no https://) and restart the bridge."
echo "For a stable hostname, create a named tunnel; see ${EXAMPLE}"
exec "${BIN}" tunnel --no-autoupdate --url "http://127.0.0.1:${PORT}"
