#!/bin/bash
toUpper 2> /dev/null || [[ "$?" == 255 ]]
