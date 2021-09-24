#!/bin/bash

MINTIELOGO=$(cat <<'END'
  __  __ ___ _   _ _____ ___ _____
 |  \/  |_ _| \ | |_   _|_ _| ____|
 | |\/| || ||  \| | | |  | ||  _|
 | |  | || || |\  | | |  | || |___
 |_|  |_|___|_| \_| |_| |___|_____|

Method for Inferring Novel Transcripts and Isoforms using Equivalences classes
END
)

while [[ $# -gt 0 ]]
do
	arg="$1"
	case $arg in
        -h)
        echo "$MINTIELOGO"
        echo ""
        echo "MINTIE wrapper script"
        echo ""
        echo "Invokes the MINTIE bpipe pileline."
        echo "See https://github.com/Oshlack/MINTIE/wiki/ for further information on using MINTIE."
        echo -e "\nusage (info): mintie [-h] "
        echo -e "\nusage (wrapper): mintie -w -p [params.txt] cases/*.fastq.gz controls/*.fastq.gz "
        echo -e "\nusage (direct):\n export \$MINTIEDIR=$PACKAGE_HOME;\n bpipe run -@$MINTIEDIR/params.txt  [ <other bpipe options >] \n\t \$MINTIEDIR/MINTIE.groovy cases/*.fastq.gz controls/*fastq.gz"
        echo ""
        exit 0
        shift
        ;;
        -w)
        ECHO=""
        shift
        ;;
        -p)
        MINTIEPARAMSFILE=$2
        shift 
        shift 
        ;;
        *)    # files
        MINTIEFILES+=("$1") 
        shift 
        ;;
    esac
done

set -- "${MINTIEFILES[@]}" 
$ECHO bpipe run @${MINTIEPARAMSFILE} $PACKAGE_HOME/MINTIE.groovy "$@"
