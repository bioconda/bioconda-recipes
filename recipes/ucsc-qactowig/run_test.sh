#!/bin/bash
qacToWig 2> /dev/null || [[ "$?" == 255 ]]
