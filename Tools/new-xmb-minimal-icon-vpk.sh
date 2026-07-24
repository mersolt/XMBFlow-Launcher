#!/usr/bin/env sh
# Build the Lua XMB smoke test with icon metadata only.
# This does not install, transfer, or otherwise interact with a Vita.
set -eu

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
vitasdk=${VITASDK:-/usr/local/vitasdk}
bin_dir="$vitasdk/bin"
stage_dir=${1:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-minimal-stage-fresh}
build_dir=${2:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-minimal-icon-build}
output_vpk=${3:-/mnt/c/Users/Hound/AppData/Local/Temp/XMBFlow-minimal-icon-smoke.vpk}
lua_entry="$root_dir/src/xmb-test.lua"

sh "$root_dir/Tools/Inspect-VitaSdkToolchain.sh"

if [ ! -d "$stage_dir" ]; then
    echo "Missing staged tree: $stage_dir" >&2
    exit 1
fi
if [ -e "$build_dir" ] || [ -e "$output_vpk" ]; then
    echo "Refusing to overwrite an existing build directory or VPK." >&2
    exit 1
fi

expected_runtime_hash=448e827a69b19da9c4f5f59de148f4d3b6c2f82ada1c023ce683e475fa9c75a5
actual_runtime_hash=$(sha256sum "$stage_dir/eboot.bin" | awk '{print $1}')
if [ "$actual_runtime_hash" != "$expected_runtime_hash" ]; then
    echo 'Runtime hash does not match the recorded safe candidate.' >&2
    exit 1
fi
for path in eboot.bin LICENSE sce_sys/icon0.png; do
    [ -f "$stage_dir/$path" ] || { echo "Missing staged file: $path" >&2; exit 1; }
done
[ -f "$lua_entry" ] || { echo "Missing Lua entry source: $lua_entry" >&2; exit 1; }

mkdir -p "$build_dir"
"$bin_dir/vita-mksfoex" -d ATTRIBUTE=0 -d PARENTAL_LEVEL=1 \
    -s APP_VER=00.01 -s TITLE_ID=XMBF00007 \
    'XMBFlow Lua Icon Smoke Test' "$build_dir/param.sfo"
"$bin_dir/vita-pack-vpk" \
    -s "$build_dir/param.sfo" \
    -b "$stage_dir/eboot.bin" \
    -a "$lua_entry=index.lua" \
    -a "$stage_dir/LICENSE=LICENSE" \
    -a "$stage_dir/sce_sys/icon0.png=sce_sys/icon0.png" \
    "$output_vpk"

echo "Created Lua icon-only XMB smoke test: $output_vpk"
sha256sum "$output_vpk"
