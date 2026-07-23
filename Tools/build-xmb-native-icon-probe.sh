#!/usr/bin/env sh
# Build a safe native installation probe with icon metadata only.
# It intentionally omits LiveArea contents to isolate that package layer.
set -eu

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
vitasdk=${VITASDK:-/usr/local/vitasdk}
bin_dir="$vitasdk/bin"
sce_sys_root=${1:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-scesys-fresh/sce_sys}
build_dir=${2:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-native-icon-probe-build}
output_vpk=${3:-/mnt/c/Users/Hound/AppData/Local/Temp/XMBFlow-native-icon-probe.vpk}

sh "$root_dir/Tools/Inspect-VitaSdkToolchain.sh"

if [ -e "$build_dir" ] || [ -e "$output_vpk" ]; then
    echo "Refusing to overwrite an existing build directory or VPK." >&2
    exit 1
fi
if [ ! -f "$sce_sys_root/icon0.png" ]; then
    echo "Missing original candidate icon: $sce_sys_root/icon0.png" >&2
    exit 1
fi

mkdir -p "$build_dir"
"$bin_dir/arm-vita-eabi-gcc" -Wall -Wextra -Werror -Wl,-q \
    "$root_dir/src/xmb-native-installer-probe.c" \
    -lSceLibKernel_stub -o "$build_dir/probe.elf"
"$bin_dir/vita-elf-create" "$build_dir/probe.elf" "$build_dir/probe.velf"
"$bin_dir/vita-make-fself" -s "$build_dir/probe.velf" "$build_dir/eboot.bin"
"$bin_dir/vita-mksfoex" -d ATTRIBUTE=0 -d PARENTAL_LEVEL=1 \
    -s APP_VER=00.01 -s TITLE_ID=XMBF00003 \
    'XMBFlow Native Icon Probe' "$build_dir/param.sfo"

"$bin_dir/vita-pack-vpk" \
    -s "$build_dir/param.sfo" \
    -b "$build_dir/eboot.bin" \
    -a "$sce_sys_root/icon0.png=sce_sys/icon0.png" \
    "$output_vpk"

echo "Created native icon-only probe: $output_vpk"
sha256sum "$output_vpk"
