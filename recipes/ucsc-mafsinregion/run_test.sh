#!/bin/bash
mafsInRegion 2> /dev/null || [[ "$?" == 255 ]]
