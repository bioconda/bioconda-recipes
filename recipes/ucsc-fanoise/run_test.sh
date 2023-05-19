#!/bin/bash
faNoise 2> /dev/null || [[ "$?" == 255 ]]
