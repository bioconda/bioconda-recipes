#!/bin/bash
faTrans 2> /dev/null || [[ "$?" == 255 ]]
