#!/bin/bash
bigWigCorrelate 2> /dev/null || [[ "$?" == 255 ]]
