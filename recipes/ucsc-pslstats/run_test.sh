#!/bin/bash
pslStats 2> /dev/null || [[ "$?" == 255 ]]
