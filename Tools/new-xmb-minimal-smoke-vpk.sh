#!/usr/bin/env sh
# Build a local candidate VPK from the verified minimal smoke-test tree.
# This script does not install, transfer, or otherwise interact with a Vita.
set -eu

stage_dir=${1:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-minimal-stage-safe}
output_vpk=${2:-/mnt/c/Users/Hound/AppData/Local/Temp/XMBFlow-minimal-smoke-safe.vpk}

if ! command -v vita-pack-vpk >/dev/null 2>&1; then
    echo "vita-pack-vpk is not on PATH; expose /usr/local/vitasdk/bin first." >&2
    exit 1
fi
if [ ! -d "$stage_dir" ]; then
    echo "Missing staged tree: $stage_dir" >&2
    exit 1
fi
if [ -e "$output_vpk" ]; then
    echo "Refusing to overwrite existing VPK: $output_vpk" >&2
    exit 1
fi

expected_runtime_hash=448e827a69b19da9c4f5f59de148f4d3b6c2f82ada1c023ce683e475fa9c75a5
actual_runtime_hash=$(sha256sum "$stage_dir/eboot.bin" | awk '{print $1}')
if [ "$actual_runtime_hash" != "$expected_runtime_hash" ]; then
    echo "Runtime hash does not match the recorded candidate." >&2
    exit 1
fi

for path in \
    index.lua LICENSE \
    sce_sys/icon0.png sce_sys/param.sfo \
    sce_sys/livearea/contents/bg.png \
    sce_sys/livearea/contents/startup.png \
    sce_sys/livearea/contents/template.xml; do
    if [ ! -f "$stage_dir/$path" ]; then
        echo "Missing staged file: $path" >&2
        exit 1
    fi
done

vita-pack-vpk \
    -s "$stage_dir/sce_sys/param.sfo" \
    -b "$stage_dir/eboot.bin" \
    -a "$stage_dir/index.lua=index.lua" \
    -a "$stage_dir/LICENSE=LICENSE" \
    -a "$stage_dir/sce_sys/icon0.png=sce_sys/icon0.png" \
    -a "$stage_dir/sce_sys/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png" \
    -a "$stage_dir/sce_sys/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png" \
    -a "$stage_dir/sce_sys/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml" \
    "$output_vpk"

echo "Created local candidate VPK: $output_vpk"
sha256sum "$output_vpk"
