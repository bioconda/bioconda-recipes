#!/bin/bash
axtToMaf 2> /dev/null || [[ "$?" == 255 ]]
