#!/bin/bash
autoSql 2> /dev/null || [[ "$?" == 255 ]]
