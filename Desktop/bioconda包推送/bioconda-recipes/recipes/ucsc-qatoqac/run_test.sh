#!/bin/bash
qaToQac 2> /dev/null || [[ "$?" == 255 ]]
