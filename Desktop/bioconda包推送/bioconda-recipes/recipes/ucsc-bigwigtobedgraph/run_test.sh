#!/bin/bash
bigWigToBedGraph 2> /dev/null || [[ "$?" == 255 ]]
