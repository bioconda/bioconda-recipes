#!/bin/bash
gapToLift 2> /dev/null || [[ "$?" == 255 ]]
