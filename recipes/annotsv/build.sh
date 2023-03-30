#!/bin/bash
set -euo pipefail

make PREFIX="${PREFIX}" install

export ANNOTSV=$(pwd)/bin/AnnotSV