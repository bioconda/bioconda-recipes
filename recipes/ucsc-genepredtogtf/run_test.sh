#!/bin/bash
genePredToGtf 2> /dev/null || [[ "$?" == 255 ]]
