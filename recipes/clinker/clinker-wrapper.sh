#!/bin/bash
CLINKERLOGO=$(cat <<'END'
      ___         ___             ___         ___         ___         ___     
     /\  \       /\__\  ___      /\__\       /\__\       /\  \       /\  \    
    /::\  \     /:/  / /\  \    /::|  |     /:/  /      /::\  \     /::\  \   
   /:/\:\  \   /:/  /  \:\  \  /:|:|  |    /:/__/      /:/\:\  \   /:/\:\  \  
  /:/  \:\  \ /:/  /   /::\__\/:/|:|  |__ /::\__\____ /::\~\:\  \ /::\~\:\  \ 
 /:/__/ \:\__/:/__/ __/:/\/__/:/ |:| /\__/:/\:::::\__/:/\:\ \:\__/:/\:\ \:\__\ 
 \:\  \  \/__\:\  \/\/:/  /  \/__|:|/:/  \/_|:|~~|~  \:\~\:\ \/__\/_|::\/:/  / 
  \:\  \      \:\  \::/__/       |:/:/  /   |:|  |    \:\ \:\__\    |:|::/  / 
   \:\  \      \:\  \:\__\       |::/  /    |:|  |     \:\ \/__/    |:|\/__/  
    \:\__\      \:\__\/__/       /:/  /     |:|  |      \:\__\      |:|  |    
     \/__/       \/__/           \/__/       \|__|       \/__/       \|__|    
END
)
# Clinker wrapper - invoke bpipe

#bpipe -p option1="something" -p option2="something_else" [...] $CLINKERDIR/workflow/clinker.pipe /path/to/*.fastq.gz
# parse and accept parameters in bpipe style, then pass on to fixed clinker.pipe location
CLINKERFILES=()
CLINKEROPTIONS=()
ECHO="echo usage: call clinker -h for more detailed information or clinker -w to run:"
while [[ $# -gt 0 ]]
do
arg="$1"

case $arg in
    -h)
    echo "$CLINKERLOGO"
    echo ""
    echo "Clinker Wrapper Script"
    echo ""
    echo "The command clinker will invoke the Clinker bpipe pipeline with simple options. Use the direct pipeline method to use any advanced bpipe features."
    echo "See https://github.com/Oshlack/Clinker/wiki/ for further information onusing Clinker."
    echo ""
    echo -e "\nusage (info): clinker [-h] "
    echo -e "\nusage (wrapper): clinker -w [-p option1=\"values\" -p option2=\"values\" ...]\" *.fastq.gz "
    echo -e "\nusage (direct):\n export \$CLINKERDIR=$PACKAGE_HOME;\n bpipe run  [-p option1=\"values\" -p option2=\"values\" ...] [ <other bpipe options >] \n\t \$CLINKERDIR/workflow/clinker.pipe *.fastq.gz"
    echo ""
    exit 0
    shift
    ;;
    -w)
    ECHO=""
    shift
    ;;
    -p)
    OPTIONNAME="${2%=*}"
    OPTIONVAL="${2#*=}"
    CLINKEROPTIONS+=("-p  $OPTIONNAME=\"$OPTIONVAL\"") 
    shift 
    shift 
    ;;
    *)    # files
    CLINKERFILES+=("$1") 
    shift 
    ;;
esac
done

set -- "${CLINKERFILES[@]}" 
$ECHO bpipe run "${CLINKEROPTIONS[@]}" $PACKAGE_HOME/workflow/clinker.pipe "$@"

