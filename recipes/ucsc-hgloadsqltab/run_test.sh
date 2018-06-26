#!/bin/bash
hgLoadSqlTab 2> /dev/null || [[ "$?" == 255 ]]
