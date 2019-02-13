#!/bin/bash
gmtime 2> /dev/null || [[ "$?" == 255 ]]
