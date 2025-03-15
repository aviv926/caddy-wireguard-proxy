# Caddy WireGuard Proxy Setup

This directory contains configuration for running Caddy as a Layer 4 reverse proxy on a VPS. The setup uses WireGuard to securely proxy requests from the VPS to your local server while preserving client IPs.

Effectively, this creates a self-hosted alternative to Clouflare Tunnels.

## Components

- **Caddy with Layer 4 Plugin**: Acts as a TCP proxy for HTTP(S) traffic, without TLS termination
- **WireGuard**: Provides secure connectivity to your local network

## Setup Instructions

1. Copy this directory to your VPS.
2. Create a `.env` file, if you'd like to customize your WireGuard configuration:
   ```
   WG_SERVER_URL=<vps-domain-or-ip>       # default: auto
   WG_SERVER_PORT=<wireguard-port>        # default: 51820
   WG_SUBNET=<wireguard-subnet>           # default: 10.13.13.0
   WG_ALLOWED_IPS=<wireguard-server-ip>   # default: 10.13.13.1
   UPSTREAM=<local-server-or-client-ips>  # default: 10.13.13.2
   WG_PEER_COUNT=<number-of-clients>      # default: 1
   ```
3. Start the containers:
   ```
   docker compose up --build --pull always -d
   ```
4. Configure your local server as a WireGuard client using
   the configuration generated in the wireguard container logs.
   You can print this configuration using:
   ```
   docker exec wireguard cat /config/peer1/peer1.conf
   ```
   (And using `cat /config/peer<n>/peer<n>.conf` for any additional clients)

   Alternatively, if you'd like to print QR codes for any additional clients, you can use:
   ```
   docker exec wireguard /app/show-peer 2 [3 4 ...]
   ```
5. Open ports 80, 443 and the WireGuard port in your VPS firewall.

6. Set up your local server to accept PROXY protocol traffic.
   For example, add the following to your local Caddyfile:

   ```Caddyfile
   (proxy_protocol) {
      proxy_protocol {
         allow 10.13.13.1/32 # Caddy Wireguard server proxy
         fallback_policy reject
      }
   }

   {
      servers :80 {
         listener_wrappers {
            import proxy_protocol
         }
      }

      servers :443 {
         strict_sni_host on

         listener_wrappers {
            import proxy_protocol
            http_redirect
            tls
         }
      }
   }

   :80 {
      # Dummy listener needed for proper operation of its listener wrapper.
      # See https://github.com/caddyserver/caddy/issues/5602#issuecomment-1611421901
   }
   ```

## How It Works

- The setup uses WireGuard to create a secure tunnel between your VPS and local server
- Caddy listens on ports 80 and 443
- Docker exposes these ports and the configured WireGuard port
- All requests are proxied at the TCP level to your local server via WireGuard
- No HTTP inspection or TLS termination occurs on the VPS
- All traffic passes through unmodified, but wrapped in PROXY protocol
- Client IPs are preserved, thanks to PROXY protocol headers

### Maintenance

- WireGuard and Caddy configurations are persisted in Docker volumes
- Docker will automatically restart these containers on reboot
