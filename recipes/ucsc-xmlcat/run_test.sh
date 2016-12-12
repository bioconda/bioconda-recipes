#!/bin/bash
xmlCat 2> /dev/null || [[ "$?" == 255 ]]
