#!/bin/bash
set -eu -o pipefail

make CXX=$CXX
cp  slimfastq "$PREFIX/bin/."
cp  tools/slimfastq.multi "$PREFIX/bin/."


