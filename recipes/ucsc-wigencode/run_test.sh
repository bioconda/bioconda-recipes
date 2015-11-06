#!/bin/bash
wigEncode 2> /dev/null || [[ "$?" == 255 ]]
