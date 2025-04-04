#!/bin/bash
bedCoverage 2> /dev/null || [[ "$?" == 255 ]]
