#!/bin/bash
set -euo pipefail

# get dir of this launcher script
DIR=$(dirname $( realpath "${BASH_SOURCE[0]}" ) )
dotnet exec $DIR/Canvas.dll "$@"
