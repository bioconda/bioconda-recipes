#!/bin/bash
bigWigMerge 2> /dev/null || [[ "$?" == 255 ]]
