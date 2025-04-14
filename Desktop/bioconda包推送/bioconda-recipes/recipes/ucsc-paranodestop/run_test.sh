#!/bin/bash
paraNodeStop 2> /dev/null || [[ "$?" == 255 ]]
