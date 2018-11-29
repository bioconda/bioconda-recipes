#!/bin/bash
rvtests --help 2> /dev/null || [[ "$?" == 255 ]]
