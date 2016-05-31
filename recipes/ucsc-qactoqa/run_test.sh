#!/bin/bash
qacToQa 2> /dev/null || [[ "$?" == 255 ]]
