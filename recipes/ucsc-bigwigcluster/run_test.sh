#!/bin/bash
bigWigCluster 2> /dev/null || [[ "$?" == 255 ]]
