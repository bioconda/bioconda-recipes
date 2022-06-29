#!/usr/bin/env bash

echo -e "\n\n*** TEST ***\n\n"

HmnTrimmer 2> /dev/null || [[ "$?" == 1 ]]
make test
