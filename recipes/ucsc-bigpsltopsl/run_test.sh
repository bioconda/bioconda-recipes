#!/bin/bash
bigPslToPsl 2> /dev/null || [[ "$?" == 255 ]]
