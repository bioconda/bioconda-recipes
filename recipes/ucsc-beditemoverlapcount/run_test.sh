#!/bin/bash
bedItemOverlapCount 2> /dev/null || [[ "$?" == 255 ]]
