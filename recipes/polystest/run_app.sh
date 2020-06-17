#!/bin/bash 
pathname=$(readlink -f ./)
echo $pathname\n
ls $pathname
R -e "shiny::runApp(\"$pathname\", port=3838)"

