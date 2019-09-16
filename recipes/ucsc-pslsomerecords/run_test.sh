#!/bin/bash
pslSomeRecords 2> /dev/null || [[ "$?" == 255 ]]
