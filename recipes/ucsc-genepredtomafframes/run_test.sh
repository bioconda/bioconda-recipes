#!/bin/bash
genePredToMafFrames 2> /dev/null || [[ "$?" == 255 ]]
