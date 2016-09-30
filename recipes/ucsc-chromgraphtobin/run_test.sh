#!/bin/bash
chromGraphToBin 2> /dev/null || [[ "$?" == 255 ]]
