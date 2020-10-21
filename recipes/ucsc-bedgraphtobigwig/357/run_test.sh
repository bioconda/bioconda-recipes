#!/bin/bash
bedGraphToBigWig 2> /dev/null || [[ "$?" == 255 ]]
