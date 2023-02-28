#!/bin/bash
webSync 2> /dev/null || [[ $? == 1 ]]
