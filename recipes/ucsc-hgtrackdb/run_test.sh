#!/bin/bash
hgTrackDb 2> /dev/null || [[ "$?" == 255 ]]
