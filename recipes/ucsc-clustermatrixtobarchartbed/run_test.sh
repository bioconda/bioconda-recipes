#!/bin/bash
clusterMatrixToBarChartBed 2> /dev/null || [[ "$?" == 255 ]]
