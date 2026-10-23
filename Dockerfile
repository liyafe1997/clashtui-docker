FROM debian:trixie-slim

ARG TARGETARCH
# Leave empty to use the latest upstream release.
ARG CLASHTUI_VERSION=""
ARG MIHOMO_VERSION=""

ENV CLASHTUI_CONFIG_DIR=/data/clashtui

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates curl fzf openrc sudo \
    && rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    latest() { curl -fsSI "https://github.com/$1/releases/latest" | tr -d '\r' | sed -n 's|^location: .*/tag/||p'; }; \
    CLASHTUI_VERSION="${CLASHTUI_VERSION:-$(latest JohanChane/clashtui)}"; \
    MIHOMO_VERSION="${MIHOMO_VERSION:-$(latest MetaCubeX/mihomo)}"; \
    ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$ARCH" in \
        amd64) MIHOMO_ARCH=amd64-compatible ;; \
        arm64) MIHOMO_ARCH=arm64 ;; \
        *) echo "unsupported arch: $ARCH" >&2; exit 1 ;; \
    esac; \
    skel=/opt/clashtui/skel; \
    mkdir -p /opt/clashtui/bin /opt/clashtui/mihomo \
        $skel/clashtui/mihomo/profiles $skel/clashtui/mihomo/templates \
        $skel/clashtui/sing-box/profiles $skel/clashtui/sing-box/templates $skel/clashtui/sing-box/proxy-providers \
        $skel/mihomo; \
    # clashtui
    curl -fsSL "https://github.com/JohanChane/clashtui/releases/download/${CLASHTUI_VERSION}/clashtui-linux-${ARCH}-${CLASHTUI_VERSION}.gz" \
        | gunzip > /opt/clashtui/bin/clashtui; \
    chmod 755 /opt/clashtui/bin/clashtui; \
    ln -sf /opt/clashtui/bin/clashtui /usr/local/bin/clashtui; \
    # mihomo
    curl -fsSL "https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-${MIHOMO_ARCH}-${MIHOMO_VERSION}.gz" \
        | gunzip > /opt/clashtui/mihomo/mihomo; \
    chmod 755 /opt/clashtui/mihomo/mihomo; \
    # default configs and templates from the matching clashtui release
    base="https://raw.githubusercontent.com/JohanChane/clashtui/${CLASHTUI_VERSION}/contrib"; \
    curl -fsSL "$base/default_configs/mihomo/core_override_config_no_tun.yaml" -o $skel/clashtui/mihomo/core_override_config.yaml; \
    # mihomo >= 1.19.33 reports stack "Mips" when unset, which clashtui cannot parse
    sed -i '/^tun:/a\  stack: mixed' $skel/clashtui/mihomo/core_override_config.yaml; \
    cp $skel/clashtui/mihomo/core_override_config.yaml $skel/mihomo/config.yaml; \
    curl -fsSL "$base/default_configs/default_keymap.yaml" -o $skel/clashtui/default_keymap.yaml; \
    curl -fsSL "$base/default_configs/default_theme.yaml" -o $skel/clashtui/default_theme.yaml; \
    for t in common_tpl generic_tpl generic_tpl_with_all generic_tpl_with_filter generic_tpl_with_ruleset; do \
        curl -fsSL "$base/templates/mihomo/$t.yaml" -o "$skel/clashtui/mihomo/templates/$t.yaml"; \
    done; \
    # geo rule files
    curl -fsSL https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb -o $skel/mihomo/geoip.metadb; \
    curl -fsSL https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat -o $skel/mihomo/GeoSite.dat; \
    printf 'clashtui %s\nmihomo %s\n' "$CLASHTUI_VERSION" "$MIHOMO_VERSION" > /opt/clashtui/versions

COPY rootfs/ /

# clashtui expects the mihomo config dir to be setgid + group-writable.
# rc-cgroup.sh only produces "No permission to apply cgroup settings" noise inside a container.
RUN chmod g+s /opt/clashtui/skel/mihomo && chmod -R g+w /opt/clashtui/skel/mihomo \
    && rm -f /usr/lib/rc/sh/rc-cgroup.sh

VOLUME /data
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
