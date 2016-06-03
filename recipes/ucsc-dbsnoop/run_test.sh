#!/bin/bash
dbSnoop 2> /dev/null || [[ "$?" == 255 ]]
