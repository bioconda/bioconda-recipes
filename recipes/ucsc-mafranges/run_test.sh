#!/bin/bash
mafRanges 2> /dev/null || [[ "$?" == 255 ]]
