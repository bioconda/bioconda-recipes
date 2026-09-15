#!/bin/bash
pslSpliceJunctions 2>/dev/null || [[ "$?" == 255 ]]
