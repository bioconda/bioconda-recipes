#!/bin/bash
# This script downloads the panel data that mykrobe uses for its predictions

cd "$PREFIX" || exit 1
TARBALL="mykrobe-data.tar.gz"
URLS=(
    "https://bit.ly/2H9HKTU"
)
SHA256="14b4e111d8b17a43dd30e3a55416bab79794ed56c44acc6238e1fd10addd0a03"
SUCCESS=0

for URL in "${URLS[@]}"; do
    wget -O - "${URL}" > "$TARBALL"
    [[ $? == 0 ]] || continue

    if [[ $(shasum -a 256 $TARBALL | cut -f1 -d " ") == "$SHA256" ]]; then
        SUCCESS=1
        break
    fi

done

if [[ $SUCCESS != 1 ]]; then
    echo "ERROR: post-link.sh was unable to download any of the following URLs with the shasum $SHA256:" >> "${PREFIX}/.messages.txt" 2>&1
    printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1
    exit 1
fi

tar -vxzf "$TARBALL"
mv $PREFIX/mykrobe-data $PREFIX/share 
cp -sr $PREFIX/share/mykrobe-data/* $PREFIX/lib/*/site-packages/mykrobe/data
rm "$TARBALL"
