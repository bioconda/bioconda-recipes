#!/bin/bash
genePredToBigGenePred 2> /dev/null || [[ "$?" == 255 ]]
