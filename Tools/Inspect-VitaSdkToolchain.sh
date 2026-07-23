#!/usr/bin/env sh
# Read-only diagnostic for the VitaSDK installation used by XMBFlow tools.
set -eu

vitasdk=${VITASDK:-/usr/local/vitasdk}
bin_dir="$vitasdk/bin"

if [ ! -d "$bin_dir" ]; then
    echo "VitaSDK bin directory not found: $bin_dir" >&2
    exit 1
fi

for tool in arm-vita-eabi-gcc vita-elf-create vita-make-fself vita-mksfoex vita-pack-vpk; do
    path="$bin_dir/$tool"
    [ -x "$path" ] || {
        echo "Required VitaSDK tool is missing or not executable: $path" >&2
        exit 1
    }
    echo "$tool=$path"
done

compiler="$bin_dir/arm-vita-eabi-gcc"
kernel_stub=$($compiler -print-file-name=libSceLibKernel_stub.a)
if [ "$kernel_stub" = 'libSceLibKernel_stub.a' ] || [ ! -f "$kernel_stub" ]; then
    echo 'VitaSDK is missing libSceLibKernel_stub.a required by the installer probe.' >&2
    exit 1
fi

echo "libSceLibKernel_stub.a=$kernel_stub"
"$compiler" --version | sed -n '1p'
