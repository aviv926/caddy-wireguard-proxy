# Caddy Tailscale Proxy Setup

This directory contains configuration for running Caddy as a Layer 4 reverse proxy on a VPS. The setup uses Tailscale to securely proxy requests from the VPS to your local server while preserving client IPs.

Effectively, this creates a self-hosted alternative to Clouflare Tunnels.

## Components

- **Caddy with Layer 4 Plugin**: Acts as a TCP proxy for HTTP(S) traffic, without TLS termination
- **Tailscale**: Provides secure connectivity to your local network

## Setup Instructions

1. Copy this directory to your VPS.
2. Create a `.env` file with your Tailscale auth key:
   ```
   TS_AUTHKEY=tskey-auth-xxx
   UPSTREAM=<local-server-tailnet-hostname>
   ```
3. Start the containers:
   ```
   docker compose up --build --pull always -d
   ```

## How It Works

- Caddy listens on ports 80 and 443
- All requests are proxied at the TCP level to your local server via Tailscale
- No HTTP inspection or TLS termination occurs on the VPS - all traffic passes through unmodified
- Client IPs are preserved, as the traffic is proxied at the TCP level

## Network Configuration

- The setup uses Tailscale's DNS to resolve the local server hostname (you can also specify its IP)
- Traffic is isolated from the host system via Docker

## Maintenance

- Tailscale state is persisted in a Docker volume
- Caddy configuration and data are also preserved in volumes
