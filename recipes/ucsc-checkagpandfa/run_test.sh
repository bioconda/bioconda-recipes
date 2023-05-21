#!/bin/bash
checkAgpAndFa 2> /dev/null || [[ "$?" == 255 ]]
