#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

mkdir -vp "${PREFIX}/bin"

# Define installation manifest
declare -A files=(
    ["bam_depth.sh"]="0755"
    ["halfdeep.sh"]="0755"
    ["halfdeep.r"]="0755"
    ["scaffold_lengths.py"]="0755"
)

# Install files
for file in "${!files[@]}"; do
    if [[ ! -f "$SRC_DIR/$file" ]]; then
        echo "Source file $file not found in $SRC_DIR" >&2
        exit 1
    fi

    if ! install -v -m "${files[$file]}" "$SRC_DIR/$file" "$PREFIX/bin/$file"; then
        echo "Failed to install $file" >&2
        exit 1
    fi
done
