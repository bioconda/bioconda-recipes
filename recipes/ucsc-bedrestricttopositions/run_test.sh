#!/bin/bash
bedRestrictToPositions 2> /dev/null || [[ "$?" == 255 ]]
