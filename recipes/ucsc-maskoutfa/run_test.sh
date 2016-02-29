#!/bin/bash
maskOutFa 2> /dev/null || [[ "$?" == 255 ]]
