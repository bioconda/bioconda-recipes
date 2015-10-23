#!/bin/bash
bigBedSummary 2> /dev/null || [[ "$?" == 255 ]]
