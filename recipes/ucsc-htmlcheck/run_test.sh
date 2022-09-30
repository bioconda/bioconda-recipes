#!/bin/bash
htmlCheck 2> /dev/null || [[ "$?" == 255 ]]
