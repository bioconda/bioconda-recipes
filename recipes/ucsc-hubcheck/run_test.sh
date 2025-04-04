#!/bin/bash
hubCheck 2> /dev/null || [[ "$?" == 255 ]]
