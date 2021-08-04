#! /usr/bin/env bash
set -e
set -x

download-vadr-models.sh caliciviridae flaviviridae
$VADRSCRIPTSDIR/testfiles/do-install-tests-local.sh
