#!/bin/bash
localtime 2> /dev/null || [[ "$?" == 255 ]]
