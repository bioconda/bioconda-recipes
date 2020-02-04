#!/usr/bin/perl
##---------------------------------------------------------------------------##
##  File:
##      @(#) RepModeleConfig.pm
##  Author:
##      Arian Smit <asmit@systemsbiology.org>
##      Robert Hubley <rhubley@systemsbiology.org>
##  Description:
##      This is the main configuration file for the RepeatModeler
##      program suite.  Before you can run the programs included
##      in this package you will need to edit this file and
##      configure for your site.  NOTE: There is also a "configure"
##      script which will help you do this.
##
#******************************************************************************
#* Copyright (C) Institute for Systems Biology 2004 Developed by
#* Arian Smit and Robert Hubley.
#*
#* This work is licensed under the Open Source License v2.1.  To view a copy
#* of this license, visit http://www.opensource.org/licenses/osl-2.1.php or
#* see the license.txt file contained in this distribution.
#*
###############################################################################
package RepModelConfig;
use FindBin;
require Exporter;
@EXPORT_OK = qw( $REPEATMODELER_DIR $REPEATMODELER_MATRICES_DIR
    $REPEATMODELER_LIB_DIR $REPEATMASKER_DIR
    $REPEATMASKER_LIB $WUBLAST_DIR $WUBLASTN_PRGM
    $WUBLASTP_PRGM $WUBLASTX_PRGM $XDFORMAT_PRGM $XDGET_PRGM
    $RECON_DIR $TRF_PRGM $RSCOUT_DIR $DEBUGALL
    $RMBLAST_DIR $RMBLASTN_PRGM $NCBIBLASTP_PRGM
    $NCBIBLASTX_PRGM $NCBIBLASTDB_PRGM $NCBIDBALIAS_PRGM
    $NCBIDBCMD_PRGM $NSEG_PRGM
);

%EXPORT_TAGS = ( all => [ @EXPORT_OK ] );
@ISA         = qw(Exporter);

BEGIN
{
##----------------------------------------------------------------------##
##     CONFIGURE THE FOLLOWING PARAMETERS FOR YOUR INSTALLATION         ##
##                                                                      ##
##
## RepeatModeler Location
## ======================
## The path to the RepeatModeler programs and support files
##
  $REPEATMODELER_DIR          = $ENV{'REPEATMODELER_DIR'};
  $REPEATMODELER_MATRICES_DIR = "$REPEATMODELER_DIR/Matrices";
  $REPEATMODELER_LIB_DIR      = "$REPEATMODELER_DIR/Libraries";

##
## RepeatMasker Location
## =====================
## The path to the RepeatMasker directory and libraries.
##
  $REPEATMASKER_DIR = $ENV{'REPEATMASKER_DIR'};
  $REPEATMASKER_LIB = "$REPEATMASKER_DIR/Libraries/RepeatMasker.lib";

##
## RMBLAST Location
## ================
## Set the location of the RMBLAST programs and support utilities.
##
  $RMBLAST_DIR      = $ENV{'RMBLAST_DIR'};
  $RMBLASTN_PRGM    = "$RMBLAST_DIR/rmblastn";
  $NCBIBLASTP_PRGM  = "$RMBLAST_DIR/blastp";
  $NCBIBLASTX_PRGM  = "$RMBLAST_DIR/blastx";
  $NCBIBLASTDB_PRGM = "$RMBLAST_DIR/makeblastdb";
  $NCBIDBALIAS_PRGM = "$RMBLAST_DIR/blastdb_aliastool";
  $NCBIDBCMD_PRGM   = "$RMBLAST_DIR/blastdbcmd";

##
## WUBLAST Location
## ================
## Set the location of the WUBLAST programs and support utilities.
##
  $WUBLAST_DIR   = $ENV{'WUBLAST_DIR'};
  $WUBLASTN_PRGM = "$WUBLAST_DIR/blastn";
  $WUBLASTP_PRGM = "$WUBLAST_DIR/blastp";
  $WUBLASTX_PRGM = "$WUBLAST_DIR/blastx";
  $XDFORMAT_PRGM = "$WUBLAST_DIR/xdformat";
  $XDGET_PRGM    = "$WUBLAST_DIR/xdget";

##
## Default Search Engine
## =====================
##  Pick which search engine should be the default
##  Can be one of "wublast", "abblast" or "ncbi".
##
  $DEFAULT_SEARCH_ENGINE = "ncbi";

##
## RECON Location
## ==============
## Zhirong Bao's RECON program suite
##
  $RECON_DIR = $ENV{'RECON_DIR'};

##
## TRF Location
## ============
## Tandem Repeat Finder program.
##
  $TRF_DIR = $ENV{'TRF_DIR'};
  $TRF_PRGM = "$TRF_DIR/trf";
##
## NSEG Location
## =============
## Location of the NCBI nseg program
  $NSEG_DIR = $ENV{'NSEG_DIR'};
  $NSEG_PRGM = "$NSEG_DIR/nseg";
##
## RepeatScout Location
## ====================
## Alkes Price RepeatScout DeNovo Repeat Finder
##
  $RSCOUT_DIR = $ENV{'RSCOUT_DIR'};

  ##
  ## Refiner Location
  ## ====================
  ##
  $REFINER_DIR = $ENV{'REFINER_DIR'};
  $REFINER_PRGM = "$REFINER_DIR/Refiner";

  ##
  ## Refiner Location
  ## ====================
  ##
  $TRFMASK_DIR = $ENV{'TRFMASK_DIR'};
  $TRFMASK_PRGM = "$TRFMASK_DIR/TRFMask";

  ##
  ## Refiner Location
  ## ====================
  ##
  $REPEATCLASSIFIER_DIR =  $ENV{'REPEATCLASSIFIER_DIR'};
  $REPEATCLASSIFIER_PRGM = "$REPEATCLASSIFIER_DIR/RepeatClassifier";

##
## Turns on debugging in all RepeatModeler modules/scripts
##
  $DEBUGALL = 0;

##                                                                      ##
##                      END CONFIGURATION AREA                          ##
##----------------------------------------------------------------------##
}

1;
