#!/bin/bash
set +e
cgview > /dev/null 2>&1
if [[ $? -eq 1 ]]
then
        pass=1
else
        pass=0
fi 

cgview_xml_builder > /dev/null 2>&1
if [[ $? -eq 255 ]] && [[ $pass -eq 1 ]]
then
	exit 0
else
	exit 1
fi
