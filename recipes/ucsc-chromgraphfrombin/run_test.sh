#!/bin/bash
chromGraphFromBin 2> /dev/null || [[ "$?" == 255 ]]
