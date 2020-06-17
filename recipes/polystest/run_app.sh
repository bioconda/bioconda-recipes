#!/bin/bash 
pathname=$(eval readlink -f ./)
echo $pathname
ls $pathname
R -e "shiny::runApp(\"$pathname\", port=3838)"

