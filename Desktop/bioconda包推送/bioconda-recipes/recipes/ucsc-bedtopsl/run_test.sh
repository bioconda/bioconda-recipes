#!/bin/bash
bedToPsl 2> /dev/null || [[ "$?" == 255 ]]
