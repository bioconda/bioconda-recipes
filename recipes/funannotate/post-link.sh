#!/usr/bin/env bash

cat >> "${PREFIX}"/.messages.txt <<- EOF
    
##########################################################################################
All Users:
  You will need to setup the funannotate databases using funannotate setup.
  The location of these databases on the file system is your decision and the
  location can be defined using the FUNANNOTATE_DB environmental variable.
  
  To set this up in your conda environment you can run the following:
    echo "export FUNANNOTATE_DB=/your/path" > ${PREFIX}/etc/conda/activate.d/funannotate.sh
    echo "unset FUNANNOTATE_DB" > ${PREFIX}/etc/conda/deactivate.d/funannotate.sh
  
  You can then run your database setup using funannotate:
    funannotate setup -i all
    
  Due to licensing restrictions, if you want to use GeneMark-ES/ET, you will need to install manually:
  download and follow directions at http://topaz.gatech.edu/GeneMark/license_download.cgi
  ** note you will likely need to change shebang line for all perl scripts:
    change: #!/usr/bin/perl to #!/usr/bin/env perl
     
      
Mac OSX Users:
  Augustus and Trinity cannot be properly installed via conda/bioconda at this time. However,
  they are able to be installed manually using a local copy of GCC (gcc-8 in example below).

  Install augustus using this repo:
    https://github.com/nextgenusfs/augustus
  
  To install Trinity v2.8.6, download the source code and compile using GCC/G++:
    wget https://github.com/trinityrnaseq/trinityrnaseq/releases/download/v2.8.6/trinityrnaseq-v2.8.6.FULL.tar.gz
    tar xzvf trinityrnaseq-v2.8.6.FULL.tar.gz
    cd trinityrnaseq-v2.8.6
    make CC=gcc-8 CXX=g++-8
    echo "export TRINITY_HOME=/your/path" > ${PREFIX}/etc/conda/activate.d/trinity.sh
    echo "unset TRINITY_HOME" > ${PREFIX}/etc/conda/deactivate.d/trinity.sh    

##########################################################################################
EOF
