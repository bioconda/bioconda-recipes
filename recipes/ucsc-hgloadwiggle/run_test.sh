#!/bin/bash
hgLoadWiggle 2> /dev/null || [[ "$?" == 255 ]]
