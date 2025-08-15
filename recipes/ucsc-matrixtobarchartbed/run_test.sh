#!/bin/bash
matrixToBarChartBed 2>/dev/null || [[ "$?" == 255 ]]
