#!/bin/bash
mafToSnpBed 2> /dev/null || [[ "$?" == 255 ]]
