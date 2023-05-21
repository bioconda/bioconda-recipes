#!/bin/bash
bigWigAverageOverBed 2> /dev/null || [[ "$?" == 255 ]]
