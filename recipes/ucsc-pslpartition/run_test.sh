#!/bin/bash
pslPartition 2> /dev/null || [[ "$?" == 255 ]]
