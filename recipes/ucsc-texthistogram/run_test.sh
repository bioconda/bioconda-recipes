#!/bin/bash
textHistogram 2> /dev/null || [[ "$?" == 255 ]]
