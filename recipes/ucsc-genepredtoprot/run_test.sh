#!/bin/bash
genePredToProt 2> /dev/null || [[ "$?" == 255 ]]
