#!/bin/sh

mkdir -p ${PREFIX}/bin
zcat REViewer-v${PKG_VERSION}-linux_x86_64.gz > ${PREFIX}/bin/REViewer
chmod +x ${PREFIX}/bin/REViewer
