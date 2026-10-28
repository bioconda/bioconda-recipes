#! /usr/bin/env bash
set -e
set -x

download-vadr-models.sh calici flavi
$VADRSCRIPTSDIR/testfiles/do-install-tests-local.sh
