#!/bin/bash
sqlToXml 2> /dev/null || [[ "$?" == 255 ]]
