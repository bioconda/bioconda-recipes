#!/bin/bash
gff3ToGenePred 2> /dev/null || [[ "$?" == 255 ]]
