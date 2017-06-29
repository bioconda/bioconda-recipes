#!/bin/bash
tailLines 2> /dev/null || [[ "$?" == 255 ]]
