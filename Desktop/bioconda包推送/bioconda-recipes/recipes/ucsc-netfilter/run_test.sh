#!/bin/bash
netFilter 2> /dev/null || [[ "$?" == 255 ]]
