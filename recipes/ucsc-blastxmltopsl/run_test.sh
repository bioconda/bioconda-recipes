#!/bin/bash
blastXmlToPsl 2> /dev/null || [[ "$?" == 255 ]]
