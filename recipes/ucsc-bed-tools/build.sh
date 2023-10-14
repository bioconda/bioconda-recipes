#!/bin/bash
mkdir -p "$PREFIX/bin"
export BINDIR=$(pwd)/bin
mkdir -p "$BINDIR"
ls

if [[ ${target_platform} =~ linux.* ]]; then
    rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/ $BINDIR/
elif [[ ${target_platform} =~ osx.* ]]; then
    rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/macOSX.x86_64/ $BINDIR/
fi

ls $BINDIR
echo ""
echo ""
ls $PREFIX

chmod +x $BINDIR/*
#cp -r $BINDIR/* "$PREFIX/bin/."
pushd $BINDIR
mv "*bed*" "$PREFIX/bin/."
mv "*Bed*" "$PREFIX/bin/."
mv "*wig*" "$PREFIX/bin/."
mv "*Wig*" "$PREFIX/bin/."
popd
