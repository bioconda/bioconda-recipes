#!/bin/bash
trfBig 2> /dev/null || [[ "$?" == 255 ]]
