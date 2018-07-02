#!/bin/bash
centroid_fold > /dev/null 2>&1 || [[ "$?" == 1 ]]
centroid_homfold > /dev/null 2>&1 || [[ "$?" == 1 ]]
centroid_alifold > /dev/null 2>&1 || [[ "$?" == 1 ]]
