#!/bin/bash
gff3ToPsl 2> /dev/null || [[ "$?" == 255 ]]
