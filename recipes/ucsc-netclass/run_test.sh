#!/bin/bash
netClass 2> /dev/null || [[ "$?" == 255 ]]
