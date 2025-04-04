#!/bin/bash
pslScore 2> /dev/null || [[ "$?" == 255 ]]
