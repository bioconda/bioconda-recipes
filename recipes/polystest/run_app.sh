#!/bin/bash 
#pathname=$(readlink -f ./)
echo $0
pathname=$(dirname $0)
echo $pathname
ls $pathname
R -e "shiny::runApp(\"$pathname\", port=3838)"

