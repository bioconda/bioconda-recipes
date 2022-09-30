#!/bin/bash
bigWigToWig 2> /dev/null || [[ "$?" == 255 ]]
