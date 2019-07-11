
# Note: $PKG_* variables are inserted above this line by the build script.


# Find original directory of bash script, resovling symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
ENV_PREFIX="$(dirname $(dirname $DIR))"
# Use Java installed with Anaconda to ensure correct version
JAVA="$ENV_PREFIX/bin/java"


function print_license_notice(){
    echo ""
    echo "  Due to license restrictions, this recipe cannot distribute "
    echo "  and install GATK directly. To fully install GATK, you must "
    echo "  download a licensed copy of GATK from the Broad Institute: "
    echo "    https://software.broadinstitute.org/gatk/download/archive "
    echo "  and run (after installing this package):"
    echo "    gatk-register /path/to/GenomeAnalysisTK[-$PKG_VERSION.tar.bz2|.jar], "
    echo "   This will copy GATK into your conda environment."
}

function print_usage(){
    echo "  Usage: $(basename $0) /path/to/GenomeAnalysisTK[-$PKG_VERSION.tar.bz2|.jar]"
}

function check_version(){
    # exits if version does not match version defined in conda package
    jar_version=$(${JAVA} -jar $1 --version | grep -oEi '[0-9]\.[0-9]')
    if [[ "$jar_version" != "$PKG_VERSION" ]]; then
        echo "The version of the jar specified, $jar_version, does not match the version expected by conda: $PKG_VERSION"
        exit 1
    else
        echo "jar file specified matches expected version"
    fi    
}

if [[ "$#" -lt 1 ]]; then
    if ! $(${JAVA} -jar $ENV_PREFIX/opt/$PKG_NAME-$PKG_VERSION/GenomeAnalysisTK.jar --version &> /dev/null); then
        echo "  It looks like GATK has not yet been installed."
        echo ""
        print_usage
        print_license_notice
        exit 1
    else
        echo "  It looks like GATK is already installed in your conda environment."
        echo "  Run:"
        echo "      gatk"
        echo "    (or)"
        echo "      GenomeAnalysisTK"
        exit 0
    fi
fi

echo "ENV_PREFIX $ENV_PREFIX"

file_ext=$(echo $1 | sed -nE 's/.*.(tar.bz2|jar)/\1/p')
archive_base=$(echo "$(basename $1)" | cut -d'.' -f-1)

if [[ "$file_ext" != "jar" && "$file_ext" != "tar.bz2" ]];then
    echo "Extension specifed is not expected: $(basename $1)"
    print_usage
    exit 1
fi

echo "Processing $(basename $1) as *.$file_ext"

mkdir -p $ENV_PREFIX/opt/$PKG_NAME-$PKG_VERSION/

if [[ "$file_ext" == "jar" ]]; then
    # copy in to conda env opt/
    if [[ "$2" != "--noversioncheck" ]]; then
      check_version $1
    fi
    echo "Copying $(basename $1) to $ENV_PREFIX/opt/$PKG_NAME-$PKG_VERSION"
    cp $1 $ENV_PREFIX/opt/$PKG_NAME-$PKG_VERSION
elif [[ "$file_ext" == "tar.bz2" ]]; then
    # extract archive and copy in
    abspath_tarball="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
    echo "Extracting $(basename $abspath_tarball)"

    mkdir /tmp/gatk
    cd /tmp/gatk
    tar -vxjf $abspath_tarball

    # jar locations: Handle both nested (GATK3.8) and non-ested (<=GATK 3.7)
    NESTED_GLOB="GenomeAnalysisTK-*/GenomeAnalysisTK.jar"
    if compgen -G "$NESTED_GLOB"; then
      JARS=( "$NESTED_GLOB" )
      JAR=( "${JARS[0]}" )
    else
      JAR=./GenomeAnalysisTK.jar
    fi
    
    if [[ "$2" != "--noversioncheck" ]]; then
      check_version $JAR
    fi
    echo "Moving $(basename $abspath_tarball) to $ENV_PREFIX/opt/$PKG_NAME-$PKG_VERSION"
    mv $JAR $ENV_PREFIX/opt/$PKG_NAME-$PKG_VERSION/
fi
