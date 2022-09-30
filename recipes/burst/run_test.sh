#!/bin/bash

burst_linux_DB15 -h 2> /dev/null || [[ "$?" == 1 ]]
burst_linux_DB12 -h 2> /dev/null || [[ "$?" == 1 ]]
lingenome -h 2> /dev/null || [[ "$?" == 1 ]]
