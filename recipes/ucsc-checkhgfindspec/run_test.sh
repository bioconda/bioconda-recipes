#!/bin/bash
checkHgFindSpec 2> /dev/null || [[ "$?" == 255 ]]
