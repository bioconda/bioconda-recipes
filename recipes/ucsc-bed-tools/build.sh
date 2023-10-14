#!/bin/bash
mkdir -p "$PREFIX/bin"

if [[ ${target_platform} =~ linux.* ]]; then
    SRC="rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/"
elif [[ ${target_platform} =~ osx.* ]]; then
    SRC="rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/macOSX.x86_64/"
fi

rsync -ap \
    --include='*/' \
    --include='*bed*' \
    --include='*bigBed' \
    --include='*ToBed*' \
    --include='*bigWig*' \
    --exclude='*' \
    "$SRC" "$PREFIX/bin/."

ls "$PREFIX/bin/"

chmod +x "$PREFIX/bin/"*
