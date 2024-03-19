#!/bin/sh

ls -laR

mkdir -p ${PREFIX}/bin
mv REViewer-v${PKG_VERSION}-linux_x86_64 ${PREFIX}/bin/REViewer
chmod +x ${PREFIX}/bin/REViewer
