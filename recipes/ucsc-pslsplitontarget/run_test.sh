#!/bin/bash
pslSplitOnTarget 2>/dev/null || [[ "$?" == 255 ]]
