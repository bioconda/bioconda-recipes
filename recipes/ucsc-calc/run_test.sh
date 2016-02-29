#!/bin/bash
calc 2> /dev/null || [[ "$?" == 255 ]]
