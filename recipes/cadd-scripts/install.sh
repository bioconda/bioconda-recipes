#!/bin/bash

usage="$(basename "$0") [-b] -- CADD installer, version 1.6

where:
    -h  show this help text
    -b  use kircherlab.bihealth.org as download server instead of krishna.gs.washington.edu

All further settings will be spcified in a yes/no dialog. 
    "

### SET FILE SERVER
DOWNLOAD_LOCATION="https://krishna.gs.washington.edu/download/CADD"

while getopts ':hb' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    b) DOWNLOAD_LOCATION=https://kircherlab.bihealth.org/download/CADD
       echo "Using kircherlab.bihealth.org as download server"
       ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND-1))

set -e

echo "CADD-v1.6 (c) University of Washington, Hudson-Alpha Institute for Biotechnology and Berlin Institute of Health 2013-2020. All rights reserved."
echo ""

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

cd $BASEDIR

# check whether conda and snakemake are available

if [ "$(type conda)" == '' ]
then
    echo 'Conda seems not to be available. Are you sure conda is installed and available in the current $PATH ?';
    exit 1;
fi

if [ "$(type snakemake)" == '' ]
then
    echo 'Snakemake seems not to be available. Are you sure snakemake is installed and available in the current $PATH ?';
    exit 1;
fi

echo "The following questions will quide you through selecting the files and dependencies needed for CADD."
echo "After this, you will see an overview of the selected files before the download and installation starts."
echo "Please note, that for successfully running CADD locally, you will need the conda environment and at least one set of annotations."
echo ""

# ask which parts of CADD the user wants to install
read -p "Do you want to install the virtual environments with all CADD dependencies via conda? (y)/n " CHOICE
case "$CHOICE" in
    y|Y ) ENV=true;;
    n|N ) ENV=false;;
    * ) ENV=true; echo "Assuming Yes.";;
esac

read -p "Do you want to install CADD v1.6 for GRCh37/hg19? (y)/n " CHOICE
case "$CHOICE" in
    y|Y ) GRCh37=true;;
    n|N ) GRCh37=false;;
    * ) GRCh37=true; echo "Assuming Yes.";;
esac

read -p "Do you want to install CADD v1.6 for GRCh38/hg38? (y)/n " CHOICE
case "$CHOICE" in
    y|Y ) GRCh38=true;;
    n|N ) GRCh38=false;;
    * ) GRCh38=true; echo "Assuming Yes.";;
esac

if [ "$GRCh37" = false ] && [ "$GRCh38" = false ]
then
    echo "You have choosen to not install any of the available CADD models. Discontinuing installation.";
    exit 0;
fi

read -p "Do you want to load annotations (Annotations can also be downloaded manually from the website)? (y)/n " CHOICE
case "$CHOICE" in
    y|Y ) ANNOTATIONS=true;;
    n|N ) ANNOTATIONS=false;;
    * ) ANNOTATIONS=true; echo "Assuming Yes.";;
esac

read -p "Do you want to load prescored variants (Makes SNV calling faster. Can also be loaded/installed later.)? y/(n) " CHOICE
case "$CHOICE" in
    y|Y ) PRESCORE=true;;
    n|N ) PRESCORE=false;;
    * ) PRESCORE=false; echo "Assuming No.";;
esac

if [ "$PRESCORE" = true ]
then
    read -p "Do you want to load prescored variants for scoring with annotations (Warning: These files are very big)? y/(n) " CHOICE
    case "$CHOICE" in
        y|Y ) INCANNO=true;;
        n|N ) INCANNO=false;;
        * ) INCANNO=false; echo "Assuming No.";;
    esac
    read -p "Do you want to load prescored variants for scoring without annotations? y/(n) " CHOICE
    case "$CHOICE" in
        y|Y ) NOANNO=true;;
        n|N ) NOCANNO=false;;
        * ) NOANNO=false; echo "Assuming No.";;
    esac
    read -p "Do you also want to load prescored InDels? We provide scores for well known InDels from sources like ClinVar, gnomAD/TOPMed etc. y/(n) " CHOICE
    case "$CHOICE" in
        y|Y ) INDELS=true;;
        n|N ) INDELS=false;;
        * ) INDELS=false; echo "Assuming No.";;
    esac
fi

### FILE CONFIGURATION
ANNOTATION_GRCh37="$DOWNLOAD_LOCATION/v1.6/GRCh37/annotationsGRCh37_v1.6.tar.gz"
ANNOTATION_GRCh38="$DOWNLOAD_LOCATION/v1.6/GRCh38/annotationsGRCh38_v1.6.tar.gz"
PRESCORE_GRCh37="$DOWNLOAD_LOCATION/v1.6/GRCh37/whole_genome_SNVs.tsv.gz"
PRESCORE_GRCh38="$DOWNLOAD_LOCATION/v1.6/GRCh38/whole_genome_SNVs.tsv.gz"
PRESCORE_INCANNO_GRCh37="$DOWNLOAD_LOCATION/v1.6/GRCh37/whole_genome_SNVs_inclAnno.tsv.gz"
PRESCORE_INCANNO_GRCh38="$DOWNLOAD_LOCATION/v1.6/GRCh38/whole_genome_SNVs_inclAnno.tsv.gz"
PRESCORE_GRCh37_INDEL="$DOWNLOAD_LOCATION/v1.6/GRCh37/InDels.tsv.gz"
PRESCORE_GRCh38_INDEL="$DOWNLOAD_LOCATION/v1.6/GRCh38/gnomad.genomes.r3.0.indel.tsv.gz"
PRESCORE_INCANNO_GRCh37_INDEL="$DOWNLOAD_LOCATION/v1.6/GRCh37/InDels_inclAnno.tsv.gz"
PRESCORE_INCANNO_GRCh38_INDEL="$DOWNLOAD_LOCATION/v1.6/GRCh38/gnomad.genomes.r3.0.indel_inclAnno.tsv.gz"

### OVERVIEW SELECTION

echo ""
echo "The following will be loaded: (disk space occupied)"

if [ "$ENV" = true ]
then
    echo " - Setup of the virtual environments including all dependencies for CADD v1.6 (10 GB)."
fi

if [ "$GRCh37" = true ]
then
    if [ "$ANNOTATIONS" = true ]
    then
        echo " - Download CADD annotations for GRCh37-v1.6 (121 GB)"
    fi

    if [ "$PRESCORE" = true ]
    then
        if [ "$INCANNO" = true ]
        then
            echo " - Download prescored SNV inclusive annotations for GRCh37-v1.6 (248 GB)"
            if [ "$INDELS" = true ]
            then
                echo " - Download prescored InDels inclusive annotations for GRCh37-v1.6 (3.4 GB)"
            fi
        fi
        if [ "$NOANNO" = true ]
        then
            echo " - Download prescored SNV (without annotations) for GRCh37-v1.6 (78 GB)"
            if [ "$INDELS" = true ]
            then
                echo " - Download prescored InDels (without annotations) for GRCh37-v1.6 (0.6 GB)"
            fi
        fi
    fi
fi

if [ "$GRCh38" = true ]
then
    if [ "$ANNOTATIONS" = true ]
    then
        echo " - Download CADD annotations for GRCh38-v1.6 (196 GB)"
    fi

    if [ "$PRESCORE" = true ]
    then
        if [ "$INCANNO" = true ]
        then
            echo " - Download prescored SNV inclusive annotations for GRCh38-v1.6 (313 GB)"
            if [ "$INDELS" = true ]
            then
                echo " - Download prescored InDels inclusive annotations for GRCh38-v1.6 (7 GB)"
            fi
        fi
        if [ "$NOANNO" = true ]
        then
            echo " - Download prescored SNV (without annotations) for GRCh38-v1.6 (81 GB)"
            if [ "$INDELS" = true ]
            then
                echo " - Download prescored InDels (without annotations) for GRCh38-v1.6 (1 GB)"
            fi
        fi
    fi
fi

echo "Please make sure you have enough disk space available."

read -p "Ready to continue? (y)/n " CHOICE
case "$CHOICE" in
    n|N ) echo "You canceled the installation."; exit 0;;
    * ) echo "Starting installation. This will take some time.";;
esac

### INSTALLATION

if [ "$ENV" = true ]
then
    echo "Setting up virtual environments for CADD v1.6"
    snakemake test/input.tsv.gz --use-conda --conda-create-envs-only --conda-prefix envs \
        --cores 1 --configfile config/config_GRCh38_v1.6.yml --snakefile Snakefile
fi

# download a file and it index and check both md5 sums
function download_variantfile()
{
    echo $1
    wget -c $2
    wget -c $2.tbi
    wget $2.md5
    wget $2.tbi.md5
    md5sum -c *.md5
    rm *.md5
}

if [ "$GRCh37" = true ]
then
    if [ "$ANNOTATIONS" = true ]
    then
        echo "Downloading CADD annotations for GRCh37-v1.6 (121 GB)"
        mkdir -p data/annotations/
        cd data/annotations/
        wget -c ${ANNOTATION_GRCh37} -O annotationsGRCh37_v1.6.tar.gz
        wget ${ANNOTATION_GRCh37}.md5 -O annotationsGRCh37_v1.6.tar.gz.md5
        md5sum -c annotationsGRCh37_v1.6.tar.gz.md5
        echo "Unpacking CADD annotations for GRCh37-v1.6"
        tar -zxf annotationsGRCh37_v1.6.tar.gz
        rm annotationsGRCh37_v1.6.tar.gz
        rm annotationsGRCh37_v1.6.tar.gz.md5
        cd $OLDPWD
    fi

    if [ "$PRESCORE" = true ]
    then
        if [ "$NOANNO" = true ]
        then
            mkdir -p data/prescored/GRCh37_v1.6/no_anno/
            cd data/prescored/GRCh37_v1.6/no_anno/
            download_variantfile "Downloading prescored SNV without annotations for GRCh37-v1.6 (78 GB)" ${PRESCORE_GRCh37}
            if [ "$INDELS" = true ]
            then
                download_variantfile "Downloading prescored InDels without annotations for GRCh37-v1.6 (0.6 GB)" ${PRESCORE_GRCh37_INDEL}
            fi
            cd $OLDPWD
        fi

        if [ "$INCANNO" = true ]
        then
            mkdir -p data/prescored/GRCh37_v1.6/incl_anno/
            cd data/prescored/GRCh37_v1.6/incl_anno/
            download_variantfile "Downloading prescored SNV inclusive annotations for GRCh37-v1.6 (248 GB)" ${PRESCORE_INCANNO_GRCh37}
            if [ "$INDELS" = true ]
            then
                download_variantfile "Downloading prescored InDels inclusive annotations for GRCh37-v1.6 (3.4 GB)" ${PRESCORE_INCANNO_GRCh37_INDEL}
            fi
            cd $OLDPWD
        fi
    fi
fi

if [ "$GRCh38" = true ]
then

    if [ "$ANNOTATIONS" = true ]
    then
        echo "Downloading CADD annotations for GRCh38-v1.6 (196 GB)"
        mkdir -p data/annotations/
        cd data/annotations/
        wget -c $ANNOTATION_GRCh38 -O annotationsGRCh38_v1.6.tar.gz
        wget $ANNOTATION_GRCh38.md5 -O annotationsGRCh38_v1.6.tar.gz.md5
        md5sum -c annotationsGRCh38_v1.6.tar.gz.md5
        echo "Unpacking CADD annotations for GRCh38-v1.6"
        tar -zxf annotationsGRCh38_v1.6.tar.gz
        rm annotationsGRCh38_v1.6.tar.gz
        rm annotationsGRCh38_v1.6.tar.gz.md5
        cd $OLDPWD
    fi

    if [ "$PRESCORE" = true ]
    then
        if [ "$NOANNO" = true ]
        then
            mkdir -p data/prescored/GRCh38_v1.6/no_anno/
            cd data/prescored/GRCh38_v1.6/no_anno/
            download_variantfile "Downloading prescored SNV without annotations for GRCh38-v1.6 (81 GB)" ${PRESCORE_GRCh38}
            if [ "$INDELS" = true ]
            then
                download_variantfile "Downloading prescored InDels without annotations for GRCh38-v1.6 (1 GB)" ${PRESCORE_GRCh38_INDEL}
            fi
            cd $OLDPWD
        fi

        if [ "$INCANNO" = true ]
        then
            mkdir -p data/prescored/GRCh38_v1.6/incl_anno/
            cd data/prescored/GRCh38_v1.6/incl_anno/
            download_variantfile "Downloading prescored SNV inclusive annotations for GRCh38-v1.6 (313 GB)" ${PRESCORE_INCANNO_GRCh38}
            if [ "$INDELS" = true ]
            then
                download_variantfile "Downloading prescored InDels inclusive annotations for GRCh38-v1.6 (7 GB)" ${PRESCORE_INCANNO_GRCh38_INDEL}
            fi
            cd $OLDPWD
        fi
    fi
fi
