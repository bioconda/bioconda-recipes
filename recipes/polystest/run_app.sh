#!/bin/bash 
DIR="$(cd "$(dirname "$0")" && pwd)"
echo $DIR
pathname=$(readlink -f $DIR)
echo $pathname
#ls $pathname
pwd
cd $DIR
pwd
R -e "shiny::runApp(\"./\", port=3838)"

