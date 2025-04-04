#!/bin/bash
hgFakeAgp 2> /dev/null || [[ "$?" == 255 ]]
