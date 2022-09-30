#!/bin/bash
hgBbiDbLink 2> /dev/null || [[ "$?" == 255 ]]
