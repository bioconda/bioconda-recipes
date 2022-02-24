#!/bin/bash
set -x
faToVcf
faToVcf 2> /dev/null || [[ "$?" == 255 ]]
