#!/bin/bash
findMotif 2> /dev/null || [[ "$?" == 255 ]]
