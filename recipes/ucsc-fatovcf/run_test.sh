#!/bin/bash
set -x
faToVcf 2> /dev/null || [[ "$?" == 1 ]]
