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
title_id=${4:-XMBF00009}
title=${5:-XMBFlow Lua Category Icons}
lua_entry="$root_dir/src/xmb-test.lua"
data_contract="$root_dir/src/addons/xmb-readonly-data.lua"

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
for icon in settings photo music video games network apps; do
    [ -f "$root_dir/assets/bootstrap-placeholders/DATA/xmb-icon-$icon.png" ] || { echo "Missing reviewed XMB category icon: $icon" >&2; exit 1; }
done
[ -f "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-sound.png" ] || { echo 'Missing reviewed sound-settings icon.' >&2; exit 1; }
[ -f "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-network.png" ] || { echo 'Missing reviewed network-settings icon.' >&2; exit 1; }
[ -f "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-theme.png" ] || { echo 'Missing reviewed theme-settings icon.' >&2; exit 1; }
for icon in xmb-setting-display xmb-setting-system xmb-setting-time xmb-object-photoviewer; do
    [ -f "$root_dir/assets/bootstrap-placeholders/DATA/$icon.png" ] || { echo "Missing reviewed object icon: $icon" >&2; exit 1; }
done
[ -f "$root_dir/assets/bootstrap-placeholders/DATA/xmb-object-trophy.png" ] || { echo 'Missing reviewed trophy icon.' >&2; exit 1; }
[ -f "$root_dir/assets/bootstrap-placeholders/DATA/xmb-object-saved-data.png" ] || { echo 'Missing reviewed saved-data icon.' >&2; exit 1; }
[ -f "$root_dir/assets/bootstrap-placeholders/DATA/font-SawarabiGothic-Regular.ttf" ] || { echo 'Missing reviewed mockup font.' >&2; exit 1; }
[ -f "$root_dir/assets/bootstrap-placeholders/DATA/xmb-cursor.ogg" ] || { echo 'Missing original navigation sound.' >&2; exit 1; }
[ -f "$lua_entry" ] || { echo "Missing Lua entry source: $lua_entry" >&2; exit 1; }
[ -f "$data_contract" ] || { echo "Missing XMB data contract: $data_contract" >&2; exit 1; }

mkdir -p "$build_dir"
cat "$data_contract" "$lua_entry" > "$build_dir/index.lua"
"$bin_dir/vita-mksfoex" -d ATTRIBUTE=0 -d PARENTAL_LEVEL=1 \
    -s APP_VER=00.01 -s TITLE_ID="$title_id" \
    "$title" "$build_dir/param.sfo"
"$bin_dir/vita-pack-vpk" \
    -s "$build_dir/param.sfo" \
    -b "$stage_dir/eboot.bin" \
    -a "$build_dir/index.lua=index.lua" \
    -a "$stage_dir/LICENSE=LICENSE" \
    -a "$stage_dir/sce_sys/icon0.png=sce_sys/icon0.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-icon-settings.png=DATA/xmb-icon-settings.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-icon-photo.png=DATA/xmb-icon-photo.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-icon-music.png=DATA/xmb-icon-music.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-icon-video.png=DATA/xmb-icon-video.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-icon-games.png=DATA/xmb-icon-games.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-icon-network.png=DATA/xmb-icon-network.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-icon-apps.png=DATA/xmb-icon-apps.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-theme.png=DATA/xmb-setting-theme.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-sound.png=DATA/xmb-setting-sound.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-network.png=DATA/xmb-setting-network.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-display.png=DATA/xmb-setting-display.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-system.png=DATA/xmb-setting-system.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-setting-time.png=DATA/xmb-setting-time.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-object-photoviewer.png=DATA/xmb-object-photoviewer.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-object-trophy.png=DATA/xmb-object-trophy.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-object-saved-data.png=DATA/xmb-object-saved-data.png" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/xmb-cursor.ogg=DATA/xmb-cursor.ogg" \
    -a "$root_dir/assets/bootstrap-placeholders/DATA/font-SawarabiGothic-Regular.ttf=DATA/font-SawarabiGothic-Regular.ttf" \
    -a "$root_dir/assets/third-party-notices/SawarabiGothic-OFL.txt=THIRD-PARTY-NOTICES/SawarabiGothic-OFL.txt" \
    "$output_vpk"

echo "Created Lua icon-only XMB smoke test: $output_vpk"
sha256sum "$output_vpk"
