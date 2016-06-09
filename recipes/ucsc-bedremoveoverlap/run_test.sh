#!/bin/bash
bedRemoveOverlap 2> /dev/null || [[ "$?" == 255 ]]
