#!/bin/bash
set +e
blat > /dev/null 2>&1
if [[ $? -eq 255 ]]
then
	exit 0
else
	exit 1
fi
