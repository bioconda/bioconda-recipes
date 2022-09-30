#!/bin/bash
hgFindSpec 2> /dev/null || [[ "$?" == 255 ]]
