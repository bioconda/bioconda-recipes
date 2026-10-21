#!/bin/bash
bedJoinTabOffset 2> /dev/null || [[ "$?" == 255 ]]
