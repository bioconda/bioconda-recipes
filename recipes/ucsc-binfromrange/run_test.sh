#!/bin/bash
binFromRange 2> /dev/null || [[ "$?" == 255 ]]
