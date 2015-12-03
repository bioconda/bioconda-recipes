#!/bin/bash
blastToPsl 2> /dev/null || [[ "$?" == 255 ]]
