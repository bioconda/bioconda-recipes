#!/bin/bash
faSomeRecords 2> /dev/null || [[ "$?" == 255 ]]
