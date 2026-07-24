#!/usr/bin/env sh
# Build a safe Lua-runtime start probe; it does not interact with a Vita.
set -eu

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
vitasdk=${VITASDK:-/usr/local/vitasdk}
bin_dir="$vitasdk/bin"
stage_dir=${1:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-minimal-stage-fresh}
build_dir=${2:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-lua-runtime-probe-build}
output_vpk=${3:-/mnt/c/Users/Hound/AppData/Local/Temp/XMBFlow-lua-runtime-probe.vpk}

sh "$root_dir/Tools/Inspect-VitaSdkToolchain.sh"
if [ ! -d "$stage_dir" ]; then echo "Missing staged tree: $stage_dir" >&2; exit 1; fi
if [ -e "$build_dir" ] || [ -e "$output_vpk" ]; then echo 'Refusing to overwrite an existing build directory or VPK.' >&2; exit 1; fi

expected_runtime_hash=448e827a69b19da9c4f5f59de148f4d3b6c2f82ada1c023ce683e475fa9c75a5
actual_runtime_hash=$(sha256sum "$stage_dir/eboot.bin" | awk '{print $1}')
if [ "$actual_runtime_hash" != "$expected_runtime_hash" ]; then echo 'Runtime hash does not match the recorded safe candidate.' >&2; exit 1; fi
for path in eboot.bin LICENSE sce_sys/icon0.png; do [ -f "$stage_dir/$path" ] || { echo "Missing staged file: $path" >&2; exit 1; }; done

mkdir -p "$build_dir"
"$bin_dir/vita-mksfoex" -d ATTRIBUTE=0 -d PARENTAL_LEVEL=1 -s APP_VER=00.01 -s TITLE_ID=XMBF00005 'XMBFlow Lua Runtime Probe' "$build_dir/param.sfo"
"$bin_dir/vita-pack-vpk" -s "$build_dir/param.sfo" -b "$stage_dir/eboot.bin" \
    -a "$root_dir/src/xmb-lua-runtime-probe.lua=index.lua" \
    -a "$stage_dir/LICENSE=LICENSE" \
    -a "$stage_dir/sce_sys/icon0.png=sce_sys/icon0.png" "$output_vpk"

echo "Created Lua runtime probe: $output_vpk"
sha256sum "$output_vpk"
