#!/bin/bash
checkCoverageGaps 2> /dev/null || [[ "$?" == 255 ]]
