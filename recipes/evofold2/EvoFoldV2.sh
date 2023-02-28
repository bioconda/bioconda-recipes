#/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
$DIR/EvoFoldV2 -c $DIR/../include/EvoFoldConfig/ "$@"