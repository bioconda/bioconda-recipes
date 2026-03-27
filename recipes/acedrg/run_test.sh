#!/bin/bash
set -exo pipefail

TMPDIR_TEST=$(mktemp -d)
cp ligand.smi "$TMPDIR_TEST/"
cd "$TMPDIR_TEST"
acedrg -i ligand.smi -o AIN-acedrg
cd -
rm -rf "$TMPDIR_TEST"
