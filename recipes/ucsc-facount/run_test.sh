#!/bin/bash
faCount 2> /dev/null || [[ "$?" == 255 ]]
