#!/bin/bash
netSplit 2> /dev/null || [[ "$?" == 255 ]]
