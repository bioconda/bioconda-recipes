#!/bin/bash
validateManifest 2> /dev/null || [[ "$?" == 255 ]]
