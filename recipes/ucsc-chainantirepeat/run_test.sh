#!/bin/bash
chainAntiRepeat 2> /dev/null || [[ "$?" == 255 ]]
