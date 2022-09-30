#!/bin/bash
fetchChromSizes 2> /dev/null || [[ "$?" == 255 ]]
