#!/bin/bash
matrixClusterColumns 2>/dev/null || [[ "$?" == 255 ]]
