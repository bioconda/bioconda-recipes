#!/bin/bash
raSqlQuery 2> /dev/null || [[ "$?" == 255 ]]
