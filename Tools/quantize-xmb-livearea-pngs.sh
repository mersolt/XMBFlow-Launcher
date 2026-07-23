#!/usr/bin/env sh
# Create an indexed-PNG copy of the candidate sce_sys graphics for Vita install.
# The source tree is never modified.
set -eu

input_sce_sys=${1:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-scesys/sce_sys}
output_sce_sys=${2:-/mnt/c/Users/Hound/AppData/Local/Temp/xmbflow-scesys-indexed/sce_sys}

if ! command -v pngquant >/dev/null 2>&1; then
    echo "pngquant is required. Install the host tool, then run this script again." >&2
    exit 1
fi
if [ ! -d "$input_sce_sys" ]; then
    echo "Missing source sce_sys directory: $input_sce_sys" >&2
    exit 1
fi
if [ -e "$output_sce_sys" ]; then
    echo "Refusing to overwrite existing output: $output_sce_sys" >&2
    exit 1
fi

mkdir -p "$output_sce_sys/livearea/contents"
cp "$input_sce_sys/param.sfo" "$output_sce_sys/param.sfo"
cp "$input_sce_sys/livearea/contents/template.xml" "$output_sce_sys/livearea/contents/template.xml"

pngquant --force --strip --output "$output_sce_sys/icon0.png" "$input_sce_sys/icon0.png"
pngquant --force --strip --output "$output_sce_sys/livearea/contents/bg.png" "$input_sce_sys/livearea/contents/bg.png"
pngquant --force --strip --output "$output_sce_sys/livearea/contents/startup.png" "$input_sce_sys/livearea/contents/startup.png"

echo "Created indexed LiveArea PNGs in $output_sce_sys"
