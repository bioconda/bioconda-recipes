#!/bin/bash
liftOverMerge 2> /dev/null || [[ "$?" == 255 ]]
