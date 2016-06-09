#!/bin/bash
chainFilter 2> /dev/null || [[ "$?" == 255 ]]
