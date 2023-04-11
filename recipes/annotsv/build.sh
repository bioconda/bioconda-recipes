#!/bin/bash
set -euo pipefail

mv bin/INSTALL_annotations.sh ${PREFIX}/INSTALL_annotations.sh
make
make install