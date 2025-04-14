#!/bin/bash
bigWigSummary 2> /dev/null || [[ "$?" == 255 ]]
