#!/bin/bash
dbTrash 2> /dev/null || [[ "$?" == 255 ]]
