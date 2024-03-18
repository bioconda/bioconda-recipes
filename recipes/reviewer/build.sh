#!/bin/sh

mkdir -p "${PREFIX}/bin"
wget "https://github.com/Illumina/REViewer/releases/download/v${PKG_VERSION}/REViewer-v${PKG_VERSION}-linux_x86_64.gz
zcat REViewer-v${PKG_VERSION}-linux_x86_64.gz "${PREFIX}/bin/REViewer"
chmod +x "${PREFIX}/bin/REViewer"
