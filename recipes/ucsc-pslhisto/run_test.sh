#!/bin/bash
pslHisto 2> /dev/null || [[ "$?" == 255 ]]
