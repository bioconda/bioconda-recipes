#!/bin/bash
genePredSingleCover 2> /dev/null || [[ "$?" == 255 ]]
