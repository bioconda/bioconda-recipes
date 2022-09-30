#!/bin/bash
hgLoadOutJoined 2> /dev/null || [[ "$?" == 255 ]]
