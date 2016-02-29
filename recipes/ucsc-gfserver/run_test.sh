#!/bin/bash
gfServer 2> /dev/null || [[ "$?" == 255 ]]
