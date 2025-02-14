#!/bin/bash

JARFILE="met4j-toolbox.jar"

function printUsageAndHelp(){
    echo ""
    echo "Usage: $0 [package.function] [options]"
    echo "  example : $0 fr.inrae.toulouse.metexplore.met4j_toolbox.convert.Sbml2Graph -i mySbml.xml -o ./output.txt"
    echo ""
    echo '-------------------------------------------'
    java -jar $JARFILE
    exit 0
}

# no arguments
if [[ $# -eq 0 ]]; then
    printUsageAndHelp
fi;

if (echo $1 | grep '^-' &> /dev/null); then
    # first argument is an option
    echo "First argument is not a valid package name : $1"
    echo ""
    printUsageAndHelp
else
    exec java -cp $JARFILE "$@"
fi;
