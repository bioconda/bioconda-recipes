#!/bin/bash
set -e
set -u
mkdir -p $PREFIX/bin
install -m 755 bin/pcne $PREFIX/bin/
install -m 755 bin/pcne_summary $PREFIX/bin/
install -m 644 bin/PCNE_analysis.R $PREFIX/bin/
install -m 644 bin/PCNE_summary.R $PREFIX/bin/
