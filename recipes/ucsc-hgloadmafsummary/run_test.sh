#!/bin/bash
hgLoadMafSummary 2> /dev/null || [[ "$?" == 255 ]]
