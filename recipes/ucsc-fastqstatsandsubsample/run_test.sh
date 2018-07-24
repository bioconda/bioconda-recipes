#!/bin/bash
fastqStatsAndSubsample 2> /dev/null || [[ "$?" == 255 ]]
