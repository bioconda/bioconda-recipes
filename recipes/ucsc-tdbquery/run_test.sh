#!/bin/bash
tdbQuery 2> /dev/null || [[ "$?" == 255 ]]
