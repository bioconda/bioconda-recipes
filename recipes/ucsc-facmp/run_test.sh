#!/bin/bash
faCmp 2> /dev/null || [[ "$?" == 255 ]]
