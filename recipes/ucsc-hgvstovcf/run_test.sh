#!/bin/bash
hgvsToVcf 2> /dev/null || [[ "$?" == 255 ]]
