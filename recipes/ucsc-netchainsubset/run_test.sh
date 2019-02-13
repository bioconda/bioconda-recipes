#!/bin/bash
netChainSubset 2> /dev/null || [[ "$?" == 255 ]]
