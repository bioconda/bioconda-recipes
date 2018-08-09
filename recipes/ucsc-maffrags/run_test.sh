#!/bin/bash
mafFrags 2> /dev/null || [[ "$?" == 255 ]]
