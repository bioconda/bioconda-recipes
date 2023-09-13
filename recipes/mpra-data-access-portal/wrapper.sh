#!/bin/bash

set -euo pipefail

print_usage()
{
    echo "USAGE: mpra-data-access-portal [OPTIONS]"
    echo
    echo "OPTIONS:"
    echo
    echo "--help       This help screen"
    echo "--self-test  Run self-check and tests"
    echo
    echo "Shiny app is started when called without options."
}

run_self_test()
{
    cd $PACKAGE_HOME

    if [[ ! -e data ]]; then
        >&2 echo "ERROR: directory data missing: $PACKAGE_HOME/data"
        exit 1
    fi

    # Self-test currently broken.
    #Rscript run_tests.R
}

export SHINY_HOST=${SHINY_HOST-0.0.0.0}
export SHINY_PORT=${SHINY_PORT-8080}

run_server()
{
    cd $PACKAGE_HOME

    Rscript -e "shiny::runApp(port = ${SHINY_PORT}, launch.browser = FALSE, host = '${SHINY_HOST}')"
}


if [[ $# -gt 1 ]]; then
    >&2 echo "ERROR: Invalid number of arguments: $#"
    >&2 echo
    >&2 print_usage
    exit 1
elif [[ $# -eq 1 ]]; then
    if [[ "$1" == "--help" ]]; then
        print_usage
        exit 0
    elif [[ "$1" == "--self-test" ]]; then
        run_self_test
    else
        >&2 echo "ERROR: Invalid option: $1"
        >&2 echo
        >&2 print_usage
        exit 1
    fi
else
    run_server
fi
