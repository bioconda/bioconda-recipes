#!/bin/bash
set -euo pipefail
make CXX="${CXX}"
make install PREFIX="${PREFIX}"