#!/bin/bash 
DIR="$(cd "$(dirname "$0")" && pwd)"
echo $DIR
pathname=$(readlink -f $DIR)
echo $pathname
#ls $pathname
R -e "shiny::runApp(\"$DIR\", port=3838)"

