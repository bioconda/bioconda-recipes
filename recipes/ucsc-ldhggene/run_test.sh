#!/bin/bash
ldHgGene 2> /dev/null || [[ "$?" == 255 ]]
