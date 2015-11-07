#!/bin/bash
netToBed 2> /dev/null || [[ "$?" == 255 ]]
