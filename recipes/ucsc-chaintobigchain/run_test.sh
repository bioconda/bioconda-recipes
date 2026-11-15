#!/bin/bash
chainToBigChain 2> /dev/null || [[ "$?" == 255 ]]
