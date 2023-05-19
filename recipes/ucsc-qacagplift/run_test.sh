#!/bin/bash
qacAgpLift 2> /dev/null || [[ "$?" == 255 ]]
