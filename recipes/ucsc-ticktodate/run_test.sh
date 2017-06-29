#!/bin/bash
tickToDate 2> /dev/null || [[ "$?" == 255 ]]
