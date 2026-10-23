# clashtui-docker

[中文](README_ZH.md)

[clashtui](https://github.com/JohanChane/clashtui) + [mihomo](https://github.com/MetaCubeX/mihomo) in a Docker image.
Images are built from the latest upstream releases and published on the [Releases](../../releases) page (`amd64` / `arm64`).

## Usage

Download the `.tar.gz` for your architecture, then:

```sh
docker load -i clashtui-docker-*.tar.gz
docker run -d --name clashtui --network host --restart unless-stopped -v clashtui-data:/data clashtui:latest
```

mihomo starts automatically. Open the TUI to configure:

```sh
docker exec -it clashtui clashtui
```

## Notes

- `--network host` is required so the proxy ports (default `7890`, API `9090`) are reachable from the host.
- All data lives in `/data`: `/data/clashtui` (clashtui, profiles, templates) and `/data/mihomo` (mihomo config dir).
- TUN mode: add `--cap-add NET_ADMIN --device /dev/net/tun` to `docker run` and enable `tun` in `/data/clashtui/mihomo/core_override_config.yaml`.
