#!/bin/bash
makeTableList 2> /dev/null || [[ "$?" == 255 ]]
