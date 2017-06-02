#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then

    $R -e "library('$1')"

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    $R -e "library('$1')"

else
    %R% -e "library('$1')"
fi
