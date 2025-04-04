#!/bin/bash
bigBedToBed 2> /dev/null || [[ "$?" == 255 ]]
