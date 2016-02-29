#!/bin/bash
genePredCheck 2> /dev/null || [[ "$?" == 255 ]]
