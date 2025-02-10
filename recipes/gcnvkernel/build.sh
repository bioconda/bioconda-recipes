#!/bin/bash

set -x
set -euo pipefail

TMPDIR=$(mktemp -d)
unzip -d $TMPDIR gatkPythonPackageArchive.zip
cd $TMPDIR

$PYTHON setup_gcnvkernel.py install
