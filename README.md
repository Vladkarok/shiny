# Shiny Secrets

A fast, simple, single-page viewer for **Shiny Secret** server rotation in [Last War: Survival](https://play.google.com/store/apps/details?id=com.fun.lastwar.gp).

Every day a different set of servers has active Shiny Secret tasks. The rotation follows a fixed 3-day cycle. This tool shows you which servers have shinies **right now** -- no digging through spreadsheets or Discord messages.

## Live

| URL | Host |
|---|---|
| [1387.vladkarok.pp.ua](https://1387.vladkarok.pp.ua) | Self-hosted VM (Docker), fronted by a separate Caddy reverse proxy |
| [shiny.vladkarok.pp.ua](https://shiny.vladkarok.pp.ua) | Cloudflare Pages |

## Features

- Automatically shows today's active servers (13xx / 14xx range)
- Rotation anchored to 02:00 UTC (00:00 server time), DST-proof
- Live clock in your local timezone so you can verify correctness
- Countdown to next rotation
- 2-day forecast (tomorrow + day after)
- Two copy buttons: full info with date, or just the server numbers
- Click-to-copy shareable link with `?date=YYYY-MM-DD` support
- Language toggle: English, Ukrainian, French
- Language choice persisted in localStorage
- Single self-contained HTML file, no dependencies, no build step

## How the rotation works

Three server groups rotate on a 3-day cycle, anchored to 2026-02-20:

| Day in cycle | Servers |
|---|---|
| 0 | 1382, 1383, 1384, 1391, 1392, 1393, 1394, 1400, 1401, 1402, 1409, 1410, 1411 |
| 1 | 1385, 1386, 1387, 1395, 1396, 1403, 1404, 1412, 1413, 1414 |
| 2 | 1381, 1388, 1389, 1390, 1397, 1398, 1399, 1405, 1406, 1407 |

The cycle index for any date is: `((days since 2026-02-20) % 3 + 3) % 3`

Rotation happens at **02:00 UTC** daily (midnight server time).

## Deployment

### Self-hosted (Docker)

The app container serves the static site on port 8080 over plain HTTP. TLS termination, HSTS, and any reverse-proxy concerns live on a separate Caddy host — this repo no longer ships a Caddy image or Caddyfile.

```bash
git clone https://github.com/vladkarok/shiny.git
cd shiny
IMAGE_TAG=latest docker compose up -d
```

The compose file binds nginx to `10.0.88.3:8080` (LAN-only); adjust `ports:` for your network. Point your reverse proxy at `http://<this-host>:8080`.

Requires:
- Docker with Compose v2
- A reverse proxy elsewhere if you want HTTPS

### Cloudflare Pages

1. Fork this repo
2. In Cloudflare Dashboard: Pages > Create project > Connect to GitHub
3. Set **build output directory** to `public`
4. Leave build command empty
5. Deploy

### Just the HTML file

The entire app is `public/index.html`. Open it directly in a browser -- it works offline, no server needed.

## CI/CD

Tags matching `v*.*.*` trigger `.github/workflows/deploy.yml`:
1. `build` job (GitHub-hosted) builds the `shiny-web` image and pushes to GHCR.
2. `deploy` job (self-hosted runner labeled `shiny`) `scp`s `docker-compose.yml` to the app VM and runs `docker compose pull && up -d`.

The workflow also supports `workflow_dispatch` for manual redeploys of an existing image tag without rebuilding.

Cloudflare Pages auto-deploys from the `public/` directory on every push to `main`.

## Project structure

```
shiny/
├── public/
│   └── index.html           # The entire app (single file)
├── .github/
│   └── workflows/
│       └── deploy.yml       # Build to GHCR + deploy via self-hosted runner
├── Dockerfile               # Nginx Alpine for static serving
├── nginx.conf               # Nginx config (port 8080, security headers)
├── docker-compose.yml       # web service only; LAN-bound
└── README.md
```

## Why this exists

There are comprehensive Last War tools and websites out there. This project exists purely for **simplicity, convenience, and speed** -- open the page, see today's servers, copy, done.

## License

[MIT](LICENSE)
