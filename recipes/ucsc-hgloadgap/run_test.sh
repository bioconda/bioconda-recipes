#!/bin/bash
hgLoadGap 2> /dev/null || [[ "$?" == 255 ]]
