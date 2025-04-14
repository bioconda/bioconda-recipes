#!/bin/bash
pslLiftSubrangeBlat 2> /dev/null || [[ "$?" == 255 ]]
