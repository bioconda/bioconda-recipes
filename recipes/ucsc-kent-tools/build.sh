#!/bin/bash
mkdir -p "$PREFIX/bin"
export BINDIR=$(pwd)/bin
mkdir -p "$BINDIR"

if [[ ${target_platform} =~ linux.* ]]; then
  rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/ $BINDIR/
elif [[ ${target_platform} =~ osx.* ]]; then
  rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/macOSX.x86_64/ $BINDIR/
fi

chmod +x $BINDIR/*
cp $BINDIR/* "$PREFIX/bin/."

