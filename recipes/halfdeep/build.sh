#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

mkdir -vp "${PREFIX}/bin"

# Define installation manifest
declare -A files=(
    ["halfdeep.sh"]="0755"
    ["halfdeep.r"]="0755"
    ["scaffold_lengths.py"]="0755"
)

<<<<<<< HEAD
# Install files
for file in "${!files[@]}"; do
    if [[ ! -f "$SRC_DIR/$file" ]]; then
        echo "Source file $file not found in $SRC_DIR" >&2
        exit 1
    fi
=======
if ! install -v -m 0755 "$SRC_DIR/halfdeep.r" "$PREFIX/bin/halfdeep.r"; then
    echo "Failed to install halfdeep r script" >&2
    exit 1
fi
>>>>>>> 0be50793b50dcc5777f9a7ce84e792c6b3e284ff

    if ! install -v -m "${files[$file]}" "$SRC_DIR/$file" "$PREFIX/bin/$file"; then
        echo "Failed to install $file" >&2
        exit 1
    fi
done
