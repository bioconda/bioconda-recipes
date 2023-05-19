#!/bin/bash
subColumn 2> /dev/null || [[ "$?" == 255 ]]
