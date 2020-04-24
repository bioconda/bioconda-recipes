#!/bin/bash
bamToPsl 2> /dev/null || [[ "$?" == 255 ]]
