#!/usr/bin/env bash
set -eo pipefail
microhapdb --download
pytest --cov=microhapdb --pyargs microhapdb
find $PREFIX -type f -name 'hg38*' -exec rm {} \;
