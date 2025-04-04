#!/bin/bash
axtToPsl 2> /dev/null || [[ "$?" == 255 ]]
