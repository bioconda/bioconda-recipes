#!/bin/bash
autoXml 2> /dev/null || [[ "$?" == 255 ]]
