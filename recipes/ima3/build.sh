#!/bin/bash

set -eo pipefail

make
mkdir -p "${PREFIX}/bin"
cp IMa3 "${PREFIX}/bin"
