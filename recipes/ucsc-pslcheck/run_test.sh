#!/bin/bash
pslCheck 2> /dev/null || [[ "$?" == 255 ]]
