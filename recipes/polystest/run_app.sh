#!/bin/bash 
pathname=$(dirname $0)
echo $pathname
pathname=$(readlink -f $pathname)
echo $pathname
ls $pathname
R -e "shiny::runApp(\"$pathname\", port=3838)"

