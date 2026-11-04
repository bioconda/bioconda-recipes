#!/bin/bash
set -euo pipefail
$R CMD INSTALL --build . ${R_ARGS}
