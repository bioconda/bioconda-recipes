#!/bin/bash
axtSwap 2> /dev/null || [[ "$?" == 255 ]]
