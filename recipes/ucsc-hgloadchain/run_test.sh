#!/bin/bash
hgLoadChain 2> /dev/null || [[ "$?" == 255 ]]
