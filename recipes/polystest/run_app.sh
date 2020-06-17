#!/bin/bash 
#pathname=$(readlink -f ./)
pathname = $(dirname $0)
echo $pathname
ls $pathname
R -e "shiny::runApp(\"$pathname\", port=3838)"

