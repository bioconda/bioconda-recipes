#!/bin/bash
ameme 2> /dev/null || [[ "$?" == 255 ]]
