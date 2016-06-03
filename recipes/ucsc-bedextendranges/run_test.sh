#!/bin/bash
bedExtendRanges 2> /dev/null || [[ "$?" == 255 ]]
