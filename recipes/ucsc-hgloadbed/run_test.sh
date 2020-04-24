#!/bin/bash
hgLoadBed 2> /dev/null || [[ "$?" == 255 ]]
