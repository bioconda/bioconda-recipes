#!/bin/bash
matrixNormalize 2>/dev/null || [[ "$?" == 255 ]]
