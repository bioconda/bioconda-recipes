#!/bin/bash
lavToPsl 2> /dev/null || [[ "$?" == 255 ]]
