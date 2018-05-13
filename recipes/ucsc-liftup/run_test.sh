#!/bin/bash
liftUp 2> /dev/null || [[ "$?" == 255 ]]
