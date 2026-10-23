# clashtui-docker

[English](#english) | [中文](#中文)

## English

[clashtui](https://github.com/JohanChane/clashtui) + [mihomo](https://github.com/MetaCubeX/mihomo) in a Docker image.
Images are built from the latest upstream releases and published on the [Releases](../../releases) page (`amd64` / `arm64`).

### Usage

Download the `.tar.gz` for your architecture, then:

```sh
docker load -i clashtui-docker-*.tar.gz
docker run -d --name clashtui --network host --restart unless-stopped -v clashtui-data:/data clashtui:latest
```

mihomo starts automatically. Open the TUI with:

```sh
docker exec -it clashtui clashtui
```

### Notes

- `--network host` is required so the proxy ports (default `7890`, API `9090`) are reachable from the host.
- All data lives in `/data`: `/data/clashtui` (clashtui, profiles, templates) and `/data/mihomo` (mihomo config dir).
- TUN mode: add `--cap-add NET_ADMIN --device /dev/net/tun` to `docker run` and enable `tun` in `/data/clashtui/mihomo/core_override_config.yaml`.

## 中文

[clashtui](https://github.com/JohanChane/clashtui) + [mihomo](https://github.com/MetaCubeX/mihomo) 的 Docker 化。
镜像由 GitHub Actions 根据上游最新 release 自动构建，发布在 [Releases](../../releases) 页面（`amd64` / `arm64`）。

### 使用

下载对应架构的 `.tar.gz`，然后：

```sh
docker load -i clashtui-docker-*.tar.gz
docker run -d --name clashtui --network host --restart unless-stopped -v clashtui-data:/data clashtui:latest
```

mihomo 会自动启动。打开 TUI：

```sh
docker exec -it clashtui clashtui
```

### 说明

- 必须使用 `--network host`，mihomo 监听的代理端口（默认 `7890`，API `9090`）才能在主机上使用。
- 所有数据都在 `/data`：`/data/clashtui`（clashtui 配置、profiles、templates）和 `/data/mihomo`（mihomo 配置目录）。
- TUN 模式：`docker run` 时加上 `--cap-add NET_ADMIN --device /dev/net/tun`，并在 `/data/clashtui/mihomo/core_override_config.yaml` 中开启 `tun`。
