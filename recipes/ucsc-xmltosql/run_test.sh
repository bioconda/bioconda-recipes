#!/bin/bash
xmlToSql 2> /dev/null || [[ "$?" == 255 ]]
