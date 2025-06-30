#!/bin/bash
bigChainBreaks 2> /dev/null || [[ "$?" == 255 ]]
