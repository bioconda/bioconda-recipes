#!/bin/bash
clusterGenes 2> /dev/null || [[ "$?" == 255 ]]
