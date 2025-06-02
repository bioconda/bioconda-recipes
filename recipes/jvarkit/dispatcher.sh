#!/bin/bash

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CMD="$( basename "$0" )"

exec "${DIR:+${DIR}/}jvarkit" "${CMD}" "$@"
