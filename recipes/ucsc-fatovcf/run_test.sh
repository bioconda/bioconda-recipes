#!/bin/bash
set -x
set +o pipefail
faToVcf 2> /dev/null || [[ "$?" == 255 ]]
