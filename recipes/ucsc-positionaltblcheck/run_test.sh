#!/bin/bash
positionalTblCheck 2> /dev/null || [[ "$?" == 255 ]]
