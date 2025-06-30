#!/bin/bash
bigChainToChain 2> /dev/null || [[ "$?" == 255 ]]
