#!/usr/bin/env sh
# Package the safe standalone XMB entry with a complete generated placeholder
# DATA set. This script never transfers to or installs on a Vita.
set -eu

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
vitasdk=${VITASDK:-/usr/local/vitasdk}
bin_dir="$vitasdk/bin"
stage_dir=${1:?staged runtime/sce_sys directory is required}
data_dir=${2:?generated placeholder DATA directory is required}
build_dir=${3:?new build directory is required}
output_vpk=${4:?new output VPK path is required}
title_id=${5:-XMBF00031}
title=${6:-XMBFlow Full Placeholder Data Test}

sh "$root_dir/Tools/Inspect-VitaSdkToolchain.sh"
if [ -e "$build_dir" ] || [ -e "$output_vpk" ]; then echo 'Refusing to overwrite build output.' >&2; exit 1; fi
for path in eboot.bin LICENSE sce_sys/icon0.png; do [ -f "$stage_dir/$path" ] || { echo "Missing staged file: $path" >&2; exit 1; }; done
[ -d "$data_dir" ] || { echo "Missing generated DATA directory: $data_dir" >&2; exit 1; }
[ -f "$root_dir/src/addons/xmb-readonly-data.lua" ] || { echo 'Missing XMB data contract.' >&2; exit 1; }
[ -f "$root_dir/src/addons/xmb-navigation.lua" ] || { echo 'Missing XMB navigation contract.' >&2; exit 1; }
[ -f "$root_dir/src/addons/xmb-layout.lua" ] || { echo 'Missing XMB layout contract.' >&2; exit 1; }

expected_runtime_hash=448e827a69b19da9c4f5f59de148f4d3b6c2f82ada1c023ce683e475fa9c75a5
actual_runtime_hash=$(sha256sum "$stage_dir/eboot.bin" | awk '{print $1}')
[ "$actual_runtime_hash" = "$expected_runtime_hash" ] || { echo 'Runtime hash mismatch.' >&2; exit 1; }

mkdir -p "$build_dir"
cat "$root_dir/src/addons/xmb-readonly-data.lua" "$root_dir/src/addons/xmb-navigation.lua" "$root_dir/src/addons/xmb-layout.lua" "$root_dir/src/xmb-test.lua" > "$build_dir/index.lua"
"$bin_dir/vita-mksfoex" -d ATTRIBUTE=0 -d PARENTAL_LEVEL=1 -s APP_VER=00.01 -s TITLE_ID="$title_id" "$title" "$build_dir/param.sfo"
set -- "$bin_dir/vita-pack-vpk" -s "$build_dir/param.sfo" -b "$stage_dir/eboot.bin" \
    -a "$build_dir/index.lua=index.lua" -a "$stage_dir/LICENSE=LICENSE" -a "$stage_dir/sce_sys/icon0.png=sce_sys/icon0.png"
for file in "$data_dir"/*; do
    [ -f "$file" ] || continue
    set -- "$@" -a "$file=DATA/$(basename "$file")"
done
"$@" "$output_vpk"
echo "Created full-placeholder XMB smoke VPK: $output_vpk"
sha256sum "$output_vpk"
