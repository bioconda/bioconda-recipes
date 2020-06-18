#!/bin/bash 
DIR="$(cd "$(dirname "$0")" && pwd)"
pathname=$(readlink -f $pathname)
echo $pathname
#ls $pathname
R -e "shiny::runApp(\"$DIR\", port=3838)"

