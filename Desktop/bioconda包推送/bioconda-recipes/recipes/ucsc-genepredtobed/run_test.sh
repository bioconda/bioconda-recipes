#!/bin/bash
genePredToBed 2> /dev/null || [[ "$?" == 255 ]]
