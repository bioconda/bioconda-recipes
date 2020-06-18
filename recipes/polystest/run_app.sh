#!/bin/bash 
echo $0
test="$(eval PREFIX)"
echo $test
echo "what is that?"
pathname=$(dirname $0)
echo $pathname
pathname=$(readlink -f $pathname)
echo $pathname
#ls $pathname
R -e "shiny::runApp(\"$pathname\", port=3838)"

