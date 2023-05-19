#!/bin/bash
mafMeFirst 2> /dev/null || [[ "$?" == 255 ]]
