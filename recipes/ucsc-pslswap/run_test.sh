#!/bin/bash
pslSwap 2> /dev/null || [[ "$?" == 255 ]]
