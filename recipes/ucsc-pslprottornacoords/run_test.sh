#!/bin/bash
pslProtToRnaCoords 2>/dev/null || [[ "$?" == 255 ]]
