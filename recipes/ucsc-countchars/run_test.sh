#!/bin/bash
countChars 2> /dev/null || [[ "$?" == 255 ]]
