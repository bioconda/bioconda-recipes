#!/bin/bash
liftOver 2> /dev/null || [[ "$?" == 255 ]]
