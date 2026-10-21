#!/bin/bash
hgWiggle 2> /dev/null || [[ "$?" == 255 ]]
