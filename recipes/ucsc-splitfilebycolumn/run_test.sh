#!/bin/bash
splitFileByColumn 2> /dev/null || [[ "$?" == 255 ]]
