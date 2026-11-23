# Ops scripts

This template does **not** ship the original `ops/*.sh` supervisor scripts. Run the bridge with:

- Docker Compose (`docker compose up --build -d`), or
- the systemd user units in `../systemd/`, plus `scripts/tunnel.sh` if you want a host-level tunnel.

If you later add `ops/*.sh` from another fork, the reserved environment variable names are listed in the root README and `.env.example`.
