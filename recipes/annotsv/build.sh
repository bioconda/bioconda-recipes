#!/bin/bash
set -euo pipefail

make PREFIX="${PREFIX}" install
make PREFIX="${PREFIX}" install-human-annotation
make PREFIX="${PREFIX}" install-mouse-annotation

export ANNOTSV=/path/to/install/AnnotSV