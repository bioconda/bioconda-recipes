#!/bin/bash
hgsqldump 2> /dev/null || [[ "$?" == 255 ]]
