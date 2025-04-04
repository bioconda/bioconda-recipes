#!/bin/bash
set -euo pipefail

chmod +x bin/INSTALL_annotations.sh
mv bin/INSTALL_annotations.sh ${PREFIX}/bin/INSTALL_annotations.sh
make
make install