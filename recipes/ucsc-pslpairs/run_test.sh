#!/bin/bash
pslPairs 2> /dev/null || [[ "$?" == 255 ]]
