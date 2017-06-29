#!/bin/bash
faToFastq 2> /dev/null || [[ "$?" == 255 ]]
