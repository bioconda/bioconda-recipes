#!/bin/bash
pslDropOverlap 2> /dev/null || [[ "$?" == 255 ]]
