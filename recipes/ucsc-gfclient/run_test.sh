#!/bin/bash
gfClient 2> /dev/null || [[ "$?" == 255 ]]
