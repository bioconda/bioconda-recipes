#!/bin/bash
autoDtd 2> /dev/null || [[ "$?" == 255 ]]
