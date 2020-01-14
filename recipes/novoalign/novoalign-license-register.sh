#!/bin/bash

# Find original directory of bash script, resovling symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
ENV_PREFIX="$(dirname $DIR)"

LICENSE_DESTINATION="$ENV_PREFIX/bin/novoalign.lic"

function print_usage(){
    echo "This will copy a Novoalign license file (novoalign.lic) to the conda environment."
    echo "  Usage: $(basename $0) /path/to/novoalign.lic"
}

if [[ "$#" -ne 1 ]]; then
    if [[ ! -e "$LICENSE_DESTINATION" ]]; then
        echo "  It looks like a Novoalign license has not yet been installed."
        echo ""
        print_usage
        exit 1
    else
        echo "  It looks like a Novoalign license is already installed in your conda environment."
        echo "  Run:"
        echo "      novoalign"
        exit 0
    fi
fi

file_ext=$(echo $1 | sed -nE 's/.*.(lic)/\1/p')

if [[ "$file_ext" != "lic" ]]; then
    echo "Extension specifed is not expected: $(basename $1)"
    print_usage
    exit 1
fi

if [[ ! -e "$LICENSE_DESTINATION" ]]; then
    echo "Copying $(basename $1) to $ENV_PREFIX/bin"
    cp "$1" "$LICENSE_DESTINATION"
    echo "...done!"
fi
