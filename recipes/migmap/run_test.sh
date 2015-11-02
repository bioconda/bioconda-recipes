#!/bin/bash

set +e

echo "Running migmap test..." >&2
migmap -h > /dev/null 2>&1
if [[ $? == 3 ]]; then
    exit 0
else
    exit 1
fi
