#!/bin/bash
wigToBigWig 2> /dev/null || [[ "$?" == 255 ]]
