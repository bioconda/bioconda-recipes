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

downgrade_soap() {
	# ugly hack -- because v1.04 segfaults on test data but v1.03 isn't on bioconda
	cd $PACKAGE_HOME ;
	wget --no-check-certificate \
		https://sourceforge.net/projects/soapdenovotrans/files/SOAPdenovo-Trans/bin/v1.03/SOAPdenovo-Trans-bin-v1.03.tar.gz ;
	mkdir -p SOAPdenovo-Trans-bin-v1.03 ;
	tar -xvzf SOAPdenovo-Trans-bin-v1.03.tar.gz -C SOAPdenovo-Trans-bin-v1.03 && rm SOAPdenovo-Trans-bin-v1.03.tar.gz ;
	sed '/soap/d' tools.groovy > tmp.groovy && mv tmp.groovy tools.groovy ;
	echo "soapdenovotrans=\"$PACKAGE_HOME/SOAPdenovo-Trans-bin-v1.03/SOAPdenovo-Trans-127mer\"" >> tools.groovy
}

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
        echo -e "\nusage (setup references): mintie -r "
        echo -e "\nusage (setup test data): mintie -t "
        echo -e "\nusage (wrapper): mintie -w -p [params.txt] cases/*.fastq.gz controls/*.fastq.gz "
        echo -e "\nusage (downgrade SOAPdenovo-trans to v1.03): mintie --downgrade-soap "
        echo -e "\nusage (direct):\n export \$MINTIEDIR=$PACKAGE_HOME;\n bpipe run -@$MINTIEDIR/params.txt  [ <other bpipe options >] \n\t \$MINTIEDIR/MINTIE.groovy cases/*.fastq.gz controls/*fastq.gz"
        echo ""
        exit 0
        shift
        ;;
        -r)
        echo -e "Generating references...\n"
        cd $PACKAGE_HOME && ./setup_references_hg38.sh ;
        exit 0
        shift
        ;;
        -t)
        echo -e "Setting up test data...\n"
        cp -r $PACKAGE_HOME/test/data/c* . ;
        cp -r $PACKAGE_HOME/test/test_params.txt params.txt ;
        exit 0
        shift
        ;;
        --downgrade-soap)
        echo -e "Downgrading SOAPdenovo-trans...\n"
		downgrade_soap ;
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
