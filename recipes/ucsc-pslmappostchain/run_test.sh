#!/bin/bash
pslMapPostChain 2> /dev/null || [[ "$?" == 255 ]]
