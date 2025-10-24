#!/bin/bash
matrixMarketToTsv 2>/dev/null || [[ "$?" == 255 ]]
