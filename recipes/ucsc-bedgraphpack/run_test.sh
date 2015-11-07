#!/bin/bash
bedGraphPack 2> /dev/null || [[ "$?" == 255 ]]
