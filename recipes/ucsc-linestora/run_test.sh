#!/bin/bash
linesToRa 2> /dev/null || [[ "$?" == 255 ]]
