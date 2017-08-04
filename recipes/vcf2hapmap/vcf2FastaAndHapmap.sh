#!/bin/bash

tool_path=$(dirname $0)



filein=$1
fileout_label=$(date "+%Y%m%d%H%M%S")
fileout=$2
option=$3

option_text=''


if [ "$option" != "none" ]
then fileout_seq=$4 
	fileout_fa1=$5 
	filefasta=$6
	if [ "$option" == "fasta_gff" ]
		then filegff=$7
	fi
fi

if [ "$option" == "fasta" ]
then option_text="--reference $filefasta"
fi

if [ "$option" == "fasta_gff" ]
then option_text="--reference $filefasta --gff $filegff"
fi


VCF2FastaAndHapmap.pl --vcf $filein --out $fileout_label $option_text


cp  $fileout_label.hapmap $fileout ; rm $fileout_label.hapmap

if [ "$option" == "fasta_gff" ]
then cp  $fileout_label.flanking.txt $fileout_seq ; rm $fileout_label.flanking.txt ; cp  $fileout_label.gene_alignment.fas $fileout_fa1 ; rm $fileout_label.gene_alignment.fas ;
fi

if [ "$option" == "fasta" ]
then cp  $fileout_label.flanking.txt $fileout_seq ; rm $fileout_label.flanking.txt ;
fi

