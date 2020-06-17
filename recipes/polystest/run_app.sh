#!/bin/bash 
pathname=$(readlink -f ./)
echo $pathname
echo $(pathname)
pathname="\"$pathname\""
R -e "shiny::runApp($pathname, port=3838)"

