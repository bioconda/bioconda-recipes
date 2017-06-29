#!/bin/bash
faFilter 2> /dev/null || [[ "$?" == 255 ]]
