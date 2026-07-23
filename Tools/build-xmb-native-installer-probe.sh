#!/usr/bin/env sh
# Build a self-contained, safe VitaSDK installation probe.
# It does not communicate with a Vita, transfer files, or install anything.
set -eu

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
sce_sys_root=${1:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-scesys-fresh/sce_sys}
build_dir=${2:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-native-installer-probe-build}
output_vpk=${3:-/mnt/c/Users/Hound/AppData/Local/Temp/XMBFlow-native-installer-probe.vpk}

for tool in arm-vita-eabi-gcc vita-elf-create vita-make-fself vita-mksfoex vita-pack-vpk; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "$tool is not on PATH; expose /usr/local/vitasdk/bin first." >&2
        exit 1
    }
done

if [ -e "$build_dir" ] || [ -e "$output_vpk" ]; then
    echo "Refusing to overwrite an existing build directory or VPK." >&2
    exit 1
fi

for path in \
    icon0.png livearea/contents/bg.png livearea/contents/startup.png \
    livearea/contents/template.xml; do
    [ -f "$sce_sys_root/$path" ] || {
        echo "Missing original candidate sce_sys file: $sce_sys_root/$path" >&2
        exit 1
    }
done

mkdir -p "$build_dir"

arm-vita-eabi-gcc -Wall -Wextra -Werror -Wl,-q \
    "$root_dir/src/xmb-native-installer-probe.c" \
    -lSceKernel_stub -o "$build_dir/probe.elf"
vita-elf-create "$build_dir/probe.elf" "$build_dir/probe.velf"
# -s marks the FSELF safe: it cannot use unrestricted VSH APIs.
vita-make-fself -s "$build_dir/probe.velf" "$build_dir/eboot.bin"
vita-mksfoex -d ATTRIBUTE=0 -d PARENTAL_LEVEL=1 \
    -s APP_VER=00.01 -s TITLE_ID=XMBF00002 \
    'XMBFlow Native Installer Probe' "$build_dir/param.sfo"

vita-pack-vpk \
    -s "$build_dir/param.sfo" \
    -b "$build_dir/eboot.bin" \
    -a "$sce_sys_root/icon0.png=sce_sys/icon0.png" \
    -a "$sce_sys_root/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png" \
    -a "$sce_sys_root/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png" \
    -a "$sce_sys_root/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml" \
    "$output_vpk"

echo "Created native installer probe: $output_vpk"
sha256sum "$output_vpk"
