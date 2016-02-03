#!/bin/bash
pslToChain 2> /dev/null || [[ "$?" == 255 ]]
