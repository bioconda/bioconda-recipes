#!/bin/bash
# This script downloads the panel data that mykrobe uses for its predictions

function check_shasum() {
    local tarball="$1"
    local sha256="$2"

    if [[ -x "$(command -v sha256sum)" ]]; then
        if [[ $(sha256sum "$tarball" | cut -f1 -d " ") == "$sha256" ]]; then
            return 1
        fi
    elif [[ -x "$(command -v shasum)" ]]; then
        if [[ $(shasum -a 256 "$tarball" | cut -f1 -d " ") == "$sha256" ]]; then
            return 1
        fi
    else
        echo "ERROR: Could not find programs shasum or sha256sum in your PATH" 2>&1
        exit 1
    fi
    return 0
}

cd "$PREFIX" || exit 1
TARBALL="mykrobe-data.tar.gz"
URL="https://bit.ly/2H9HKTU"
SHA256="14b4e111d8b17a43dd30e3a55416bab79794ed56c44acc6238e1fd10addd0a03"

wget -O "$TARBALL" "$URL"

check_shasum "$TARBALL" "$SHA256"
SUCCESS="$?"


if [[ "$SUCCESS" -ne 1 ]]; then
    echo "ERROR: post-link.sh was unable to download the following URL with the shasum $SHA256:" >> "${PREFIX}/.messages.txt" 2>&1
    printf '%s\n' "${URL}" >> "${PREFIX}/.messages.txt" 2>&1
    exit 1
fi

tar -vxzf "$TARBALL"
mv "${PREFIX}/mykrobe-data" "${PREFIX}/share"
cp -sr "$PREFIX"/share/mykrobe-data/* "$PREFIX"/lib/*/site-packages/mykrobe/data
rm "$TARBALL"
