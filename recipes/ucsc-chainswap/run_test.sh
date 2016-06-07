#!/bin/bash
chainSwap 2> /dev/null || [[ "$?" == 255 ]]
