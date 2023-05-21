#!/bin/bash
axtChain 2> /dev/null || [[ "$?" == 255 ]]
