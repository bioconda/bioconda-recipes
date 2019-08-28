#!/usr/bin/perl
##---------------------------------------------------------------------------##
##  File:
##      @(#) RepeatMaskerConfig.pm
##  Author:
##      Arian Smit <asmit@systemsbiology.org>
##      Robert Hubley <rhubley@systemsbiology.org>
##  Description:
##      This is the main configuration file for the RepeatMasker
##      program suite.  Before you can run the programs included
##      in this package you will need to edit this file and
##      configure for your site.  NOTE: There is also a "configure"
##      script which will help you do this.
##
#******************************************************************************
#* Copyright (C) Institute for Systems Biology 2005 Developed by
#* Arian Smit and Robert Hubley.
#*
#* This work is licensed under the Open Source License v2.1.  To view a copy
#* of this license, visit http://www.opensource.org/licenses/osl-2.1.php or
#* see the license.txt file contained in this distribution.
#*
###############################################################################
package RepeatMaskerConfig;
use FindBin;
require Exporter;
@EXPORT_OK = qw( $REPEATMASKER_DIR $REPEATMASKER_MATRICES_DIR
    $REPEATMASKER_LIB_DIR $WUBLAST_DIR $WUBLASTN_PRGM
    $WUBLASTP_PRGM $WUBLASTX_PRGM $SETDB_PRGM $XDFORMAT_PRGM 
    $DEMAKE $DECYPHER $LIBPATH $TRF_PRGM $DEBUGALL $VALID_SEARCH_ENGINES
    $DEFAULT_SEARCH_ENGINES $RMBLAST_DIR $RMBLASTN_PRGM $RMBLASTDB_PRGM );

%EXPORT_TAGS = ( all => [ @EXPORT_OK ] );
@ISA         = qw(Exporter);

BEGIN {
##----------------------------------------------------------------------##
##     CONFIGURE THE FOLLOWING PARAMETERS FOR YOUR INSTALLATION         ##
##                                                                      ##
##
## RepeatMasker Location
## ======================
## The path to the RepeatMasker programs and support files
## This is the directory with this file as well as
## the ProcessRepeats and Library/ and Matrices/ subdirectories
## reside.
##
##    i.e. Typical UNIX installation
##     $REPEATMASKER_DIR = "/usr/local/RepeatMasker";
##    Windows w/Cygwin example:
##     $REPEATMASKER_DIR = "/cygdrive/c/RepeatMasker";
##
  foreach $var (qw(REPEATMASKER_DIR REPEATMASKER_MATRICES_DIR REPEATMASKER_LIB_DIR)) {
      die "environment variable $var not defined" if !defined($ENV{$var});
      die "directory (" . $ENV{$var} . ") does not exist for $var" unless (-d $ENV{$var});
  }

  $REPEATMASKER_DIR          = $ENV{'REPEATMASKER_DIR'};
  $REPEATMASKER_MATRICES_DIR = $ENV{'REPEATMASKER_MATRICES_DIR'};
  $REPEATMASKER_LIB_DIR      = $ENV{'REPEATMASKER_LIB_DIR'};

##
## Search Engine Configuration:
##   RepeatMasker uses either the CrossMatch, RMBlast, WUBlast/ABBlast, 
##   or the HMMER search engine to find matches to interspersed
##   repeat consensi or profile HMMs.  You are only required to have one engine
##   installed on your system in order to run RepeatMasker.  
##   
##   The optional program RepeatProteinMask will only run
##   with the RMBlast or WUBlast/ABBlast package ( currently ).  
##

  ##
  ## CrossMatch Location
  ## ===================
  ## The path to Phil Green's cross_match program ( phrap program suite ).
  ##   - Use cross_match version 980501 or later for best results
  ##   - On a windows machine running the cygwin emulation software
  ##     you might set this to something like this:
  ##
  ##            $CROSSMATCH_DIR = "/cygdrive/c/phrap";
  ##            $CROSSMATCH_PRGM = "cross_match.exe";
  ##
    $CROSSMATCH_DIR = $ENV{'CROSSMATCH_DIR'};
    $CROSSMATCH_PRGM = "$CROSSMATCH_DIR/cross_match";

  ##
  ## HMMER Location
  ## ========================
  ## Set the location of the HMMER programs and support utilities.
  ##
    $HMMER_DIR   = $ENV{'HMMER_DIR'};
    $NHMMSCAN_PRGM = "$HMMER_DIR/nhmmscan";
    $HMMPRESS_PRGM = "$HMMER_DIR/hmmpress";

  ##
  ## RMBlast Location
  ## ========================
  ## Set the location of the NCBI RMBLAST programs and support utilities.
  ##
    $RMBLAST_DIR   = $ENV{'RMBLAST_DIR'};
    $RMBLASTN_PRGM = "$RMBLAST_DIR/rmblastn";
    $RMBLASTX_PRGM = "$RMBLAST_DIR/blastx";
    $RMBLASTDB_PRGM   = "$RMBLAST_DIR/makeblastdb";
 
  ##
  ## WUBLAST/ABBlast Location
  ## ========================
  ## Set the location of the WUBLAST/ABBlast programs and support utilities.
  ##
    $WUBLAST_DIR   = $ENV{'WUBLAST_DIR'};
    $WUBLASTN_PRGM = "$WUBLAST_DIR/blastn";
    $WUBLASTP_PRGM = "$WUBLAST_DIR/blastp";
    $WUBLASTX_PRGM = "$WUBLAST_DIR/blastx";
    $XDFORMAT_PRGM = "$WUBLAST_DIR/xdformat";
    $SETDB_PRGM    = "$WUBLAST_DIR/setdb";
  
##
## Default Search Engine
## =====================
##  Pick which search engine should be the default
##  Can be one of "crossmatch", "wublast", "decypher" or "ncbi".
##
  $DEFAULT_SEARCH_ENGINE = "ncbi";


##
## Library Path
## ============
##   - RepeatMasker now generates and caches
##     species specific libraries.  The LIBPATH 
##     parameter defines the search order for
##     directories where library caches might
##     be stored.  NOTE: RepeatMasker needs at
##     least one of these directories to be writable
##     and thus if it can't read a cached library
##     from one of these locations, or write
##     a new library in one of these locations it
##     will default to building the libraries
##     in the programs work directory every time
##     it runs -- this could be slow if you commonly
##     run against short sequences using the same
##     species parameters.
##
  
  @LIBPATH = ( $REPEATMASKER_LIB_DIR, 
               $ENV{'HOME'} . "/.RepeatMaskerCache" );
  if (defined($ENV{'REPEATMASKER_CACHE_DIR'})) {
    unshift(@LIBPATH, $ENV{'REPEATMASKER_CACHE_DIR'});
  }

##
## TRF Location ( OPTIONAL )
## ============
## Tandem Repeat Finder program.  This is only required by
## the RepeatProteinMask program.
##
  $TRF_PRGM = $ENV{'TRF_DIR'} . "/trf";

##
## Turns on debugging in all RepeatMasker modules/scripts
##
  $DEBUGALL = 0;

##                                                                      ##
##                      END CONFIGURATION AREA                          ##
##----------------------------------------------------------------------##

##----------------------------------------------------------------------##
## Do not change these parameters
##
  $VALID_SEARCH_ENGINES = { "crossmatch" => 1, 
                            "wublast" => 1
                          };

##----------------------------------------------------------------------##
}

1;
