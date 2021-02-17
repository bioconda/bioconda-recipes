#!/usr/bin/perl
##---------------------------------------------------------------------------##
##  File:
##      @(#) RepModelConfig.pm
##  Author:
##      Arian Smit <asmit@systemsbiology.org>
##      Robert Hubley <rhubley@systemsbiology.org>
##  Description:
##      This is the main configuration file for the RepeatModeler
##      program suite.  Before you can run the programs included
##      in this package you will need to run the "./configure" program
##      to modify this file or manually edit in an editor.
##
#******************************************************************************
#* Copyright (C) Institute for Systems Biology 2004-2019 Developed by
#* Arian Smit and Robert Hubley.
#*
#* This work is licensed under the Open Source License v2.1.  To view a copy
#* of this license, visit http://www.opensource.org/licenses/osl-2.1.php or
#* see the license.txt file contained in this distribution.
#*
###############################################################################
package RepModelConfig;
use FindBin;
use File::Basename;
use Data::Dumper;
require Exporter;
@EXPORT_OK   = qw();
%EXPORT_TAGS = ( all => [ @EXPORT_OK ] );
@ISA         = qw(Exporter);
my $CLASS = "RepModelConfig";

BEGIN {
##----------------------------------------------------------------------##
##     CONFIGURE THE FOLLOWING PARAMETERS FOR YOUR INSTALLATION         ##
##                                                                      ##
##  This file may be hand edited or preferably, modified with the       ##
##  the use of the "configure" script.                                  ##
##                                                                      ##
##  In the following section default values for paths/programs          ##
##  may be hardcoded. Each parameter appears in a block of text         ##
##  below as:                                                           ##
##                                                                      ##
##    PARAMETER_NAME => {                                               ##
##                 ...                                                  ##
##              value => "/usr/local/bin/foo"                           ##
##                      }                                               ##
##                                                                      ##
##  only change the "value" field for each parameter. If you are        ##
##  unsure of how to edit this file, simply use the the ./configure     ##
##  script provided with the package to perform the same task.  For     ##
##  more details on configuring this package please see the README      ##
##  file.                                                               ##
##                                                                      ##
  ## STCFG --do-not-remove--
  $configuration = {
          'ABBLAST_DIR' => {
                             'command_line_override' => 'abblast_dir',
                             'description' => 'The path to the installation of the ABBLAST sequence alignment program.',
                             'environment_override' => 'ABBLAST_DIR',
                             'expected_binaries' => [
                                                      'blastp'
                                                    ],
                             'param_type' => 'directory',
                             'required' => 0,
                             'value' => $ENV{'ABBLAST_DIR'}
                           },
          'CDHIT_DIR' => {
                           'command_line_override' => 'cdhit_dir',
                           'description' => 'The path to the installation of the CD-Hit sequence clustering package.',
                           'environment_override' => 'CDHIT_DIR',
                           'expected_binaries' => [
                                                    'cd-hit'
                                                  ],
                           'param_type' => 'directory',
                           'required' => 0,
                           'value' => $ENV{'CDHIT_DIR'}
                         },
          'GENOMETOOLS_DIR' => {
                                 'command_line_override' => 'genometools_dir',
                                 'description' => 'The path to the installation of the GenomeTools package.',
                                 'environment_override' => 'GENOMETOOLS_DIR',
                                 'expected_binaries' => [
                                                          'gt'
                                                        ],
                                 'param_type' => 'directory',
                                 'required' => 0,
                                 'value' => $ENV{'GENOMETOOLS_DIR'}
                               },
          'LTR_RETRIEVER_DIR' => {
                                   'command_line_override' => 'ltr_retriever_dir',
                                   'description' => 'The path to the installation of the LTR_Retriever structural LTR analysis package.',
                                   'environment_override' => 'LTR_RETRIEVER_DIR',
                                   'expected_binaries' => [
                                                            'LTR_retriever'
                                                          ],
                                   'param_type' => 'directory',
                                   'required' => 0,
                                   'value' => $ENV{'LTR_RETRIEVER_DIR'}
                                 },
          'MAFFT_DIR' => {
                           'command_line_override' => 'mafft_dir',
                           'description' => 'The path to the installation of the MAFFT multiple alignment program.',
                           'environment_override' => 'MAFFT_DIR',
                           'expected_binaries' => [
                                                    'mafft'
                                                  ],
                           'param_type' => 'directory',
                           'required' => 0,
                           'value' => $ENV{'MAFFT_DIR'}
                         },
          'NINJA_DIR' => {
                           'command_line_override' => 'ninja_dir',
                           'description' => 'The path to the installation of the Ninja phylogenetic analysis package.',
                           'environment_override' => 'NINJA_DIR',
                           'expected_binaries' => [
                                                    'Ninja'
                                                  ],
                           'param_type' => 'directory',
                           'required' => 0,
                           'value' => $ENV{'NINJA_DIR'}
                         },
          'RECON_DIR' => {
                           'command_line_override' => 'recon_dir',
                           'description' => 'The path to the installation of the RECON de-novo repeatfinding program.',
                           'environment_override' => 'RECON_DIR',
                           'expected_binaries' => [
                                                    'eledef',
                                                    'eleredef'
                                                  ],
                           'param_type' => 'directory',
                           'required' => 1,
                           'value' => $ENV{'RECON_DIR'}
                         },
          'REPEATMASKER_DIR' => {
                                  'command_line_override' => 'repeatmasker_dir',
                                  'description' => 'The path to the installation of RepeatMasker.',
                                  'environment_override' => 'REPEATMASKER_DIR',
                                  'expected_binaries' => [
                                                           'RepeatMasker'
                                                         ],
                                  'param_type' => 'directory',
                                  'required' => 1,
                                  'value' => $ENV{'REPEATMASKER_DIR'}
                                },
          'RMBLAST_DIR' => {
                             'command_line_override' => 'rmblast_dir',
                             'description' => 'The path to the installation of the RMBLAST sequence alignment program.',
                             'environment_override' => 'RMBLAST_DIR',
                             'expected_binaries' => [
                                                      'rmblastn',
                                                      'dustmasker',
                                                      'makeblastdb',
                                                      'blastdbcmd',
                                                      'blastdb_aliastool',
                                                      'blastn'
                                                    ],
                             'param_type' => 'directory',
                             'required' => 1,
                             'value' => $ENV{'RMBLAST_DIR'}
                           },
          'RSCOUT_DIR' => {
                            'command_line_override' => 'rscout_dir',
                            'description' => 'The path to the installation of the RepeatScout ( 1.0.6 or higher ) de-novo repeatfinding program.',
                            'environment_override' => 'RSCOUT_DIR',
                            'expected_binaries' => [
                                                     'RepeatScout',
                                                     'build_lmer_table'
                                                   ],
                            'param_type' => 'directory',
                            'required' => 1,
                            'value' => $ENV{'RSCOUT_DIR'}
                          },
          'TRF_PRGM' => {
                          'command_line_override' => 'trf_prgm',
                          'description' => 'The full path including the name for the TRF program ( 4.0.9 or higher )',
                          'environment_override' => 'TRF_PRGM',
                          'param_type' => 'program',
                          'required' => 1,
                          'value' => $ENV{'TRF_PRGM'}
                        }
        };

  ## EDCFG --do-not-remove--

##                                                                      ##
##                      END CONFIGURATION AREA                          ##
##----------------------------------------------------------------------##
##----------------------------------------------------------------------##
##  Do not edit below this line                                         ##
##----------------------------------------------------------------------##

  #
  # Current version of the software
  #
  $VERSION = "2.0.1";

  #
  # Set this flag to default to debug mode for the entire package
  #
  $DEBUGALL = 0;

  #
  # Prompt for a specific parameter and update the object
  #
  sub promptForParam {
    my $param     = shift;
    my $screenHdr = shift;

    if ( !exists $configuration->{$param} ) {
      return;
    }

    # Grab defaults
    my $defaultValue;
    if ( $configuration->{$param}->{'param_type'} eq "directory" ) {
      if ( exists $configuration->{$param}->{'expected_binaries'}
           && @{ $configuration->{$param}->{'expected_binaries'} } )
      {
        my $binary = $configuration->{$param}->{'expected_binaries'}->[ 0 ];
        $defaultValue = `/usr/bin/which $binary`;
        if ( $defaultValue !~ /\/usr\/bin\/which:/ ) {
          $defaultValue =~ s/[\n\r\s]+//g;
          $defaultValue =~ s/^(.*)\/$binary/$1/;
        }
        else {
          $defaultValue = "";
        }
      }
      if (    $defaultValue eq ""
           && exists $configuration->{$param}->{'value'}
           && -d $configuration->{$param}->{'value'} )
      {
        $defaultValue = $configuration->{$param}->{'value'};
      }
    }
    elsif ( $configuration->{$param}->{'param_type'} eq "program" ) {

      # The program type is used in cases where a single
      # script/binary is referenced and may not have the
      # exact name we expect.  TRF is a good example of this
      # as the binary is often distributed with names like:
      # trf409.linux64 etc..
      if ( exists $configuration->{$param}->{'value'} ) {
        my ( $binary, $dirs, $suffix ) =
            fileparse( $configuration->{$param}->{'value'} );
        $defaultValue = `/usr/bin/which $binary`;
        if ( $defaultValue !~ /\/usr\/bin\/which:/ ) {
          $defaultValue =~ s/[\n\r\s]+//g;
        }
        else {
          $defaultValue = $configuration->{$param}->{'value'};
        }
      }
    }

    my $value = "";
    my $validParam;
    do {
      $validParam = 1;
      system( "clear" );
      if ( $screenHdr ) {
        print "$screenHdr\n";
      }
      else {
        print "\n\n\n\n";
      }
      print "" . $configuration->{$param}->{'description'} . "\n";

      # Prompt and get the value
      if ( $defaultValue ) {
        print "$param [$defaultValue]: ";
      }
      else {
        print "$param: ";
      }
      $value = <STDIN>;
      $value =~ s/[\n\r]+//g;
      if ( $value eq "" && $defaultValue ) {
        $value = $defaultValue;
      }

      if ( $configuration->{$param}->{'param_type'} eq "directory" ) {
        if ( -d $value ) {
          foreach my $binary (
                          @{ $configuration->{$param}->{'expected_binaries'} } )
          {
            if ( !-x "$value/$binary" ) {
              print "\nCould not find the required program \"$binary\" inside\n"
                  . "the directory \"$value\"!\n\n";
              $validParam = 0;
              last;
            }
            elsif ( -d "$value/$binary" ) {
              print "\nCould not find the required program \"$binary\" inside\n"
                  . "the directory \"$value\"!  It appears to be the name of a\n"
                  . "subdirectory.\n\n";
              $validParam = 0;
              last;
            }
          }
        }
        else {
          print "\nCould not find the \"$value\" directory.\n\n";
          $validParam = 0;
        }
      }
      elsif ( $configuration->{$param}->{'param_type'} eq "program" ) {
        if ( !-x $value ) {
          print "\nThe program \"$value\" doesn't appear to exist\n"
              . "or it's not executable!\n\n";
          $validParam = 0;
        }
        elsif ( -d $value ) {
          print "\nThe value \"$value\" appears to be a directory rather\n"
              . "than an executable binary or script!\n\n";
          $validParam = 0;
        }
      }

      if ( $validParam == 0 ) {
        print "<PRESS ENTER TO CONTINUE, CTRL-C TO BREAK>\n";
        <STDIN>;
      }
    } while ( $validParam == 0 );
    $configuration->{$param}->{'value'} = $value;
    #my $version = &getDependencyVersion($param);
    #if ( $version ) {
    #  $configuration->{$param}->{'version'} = $version;
    #}
  }

  #
  # Validate parameter
  #
  sub validateParam {
    my $param       = shift;
    my $new_setting = shift;

    if ( !exists $configuration->{$param} ) {
      return 0;
    }

    my $value = $configuration->{$param}->{'value'};
    $value = $new_setting if ( defined $new_setting );


    # Always assume the "good" in parameters...
    my $validParam = 1;
    if ( $configuration->{$param}->{'param_type'} eq "directory" ) {
      if ( -d $value ) {
        foreach
            my $binary ( @{ $configuration->{$param}->{'expected_binaries'} } )
        {
          if ( !-x "$value/$binary" ) {
            $validParam = 0;
            last;
          }
          elsif ( -d "$value/$binary" ) {
            $validParam = 0;
            last;
          }
        }
      }
      else {
        $validParam = 0;
      }
    }
    elsif ( $configuration->{$param}->{'param_type'} eq "program" ) {
      if ( !-x $value ) {
        $validParam = 0;
      }
      elsif ( -d $value ) {
        $validParam = 0;
      }
    }

    # TODO Validate versions
    #if ( $validParam ) {
    #  my $version = &getDependencyVersion($param);
    #  if ( $version ) {
    #    $configuration->{$param}->{'version'} = $version;
    #  }
    #}

    return $validParam;
  }

  #
  # Update this file ( beware: self modifying code ) new
  # paramter settings.
  #
  sub updateConfigFile {
    open IN,  "<$CLASS.pm"     or die;
    open OUT, ">new-$CLASS.pm" or die;
    my $inCfg;
    $Data::Dumper::Sortkeys = 1;
    while ( <IN> ) {
      if ( /##\s+STCFG/ ) {
        $inCfg = 1;
        print OUT;
        my $cStr = Dumper( $configuration );
        $cStr =~ s/\$VAR1/  \$configuration/;
        print OUT "$cStr\n";
      }
      elsif ( /##\s+EDCFG/ ) {
        $inCfg = 0;
        print OUT;
      }
      elsif ( !$inCfg ) {
        print OUT;
      }
    }
    close IN;
    close OUT;
    rename( "$CLASS.pm",     "$CLASS.pm.bak" );
    rename( "new-$CLASS.pm", "$CLASS.pm" );
  }

  #
  # Create a GetOpt list for the command-line parameters defined
  # in this configuration file.  These may be appended to a program's
  # existing GetOpt parameter as:
  #
  #     push @getopt_args, RepModelConfig::getCommandLineOptions();
  #
  sub getCommandLineOptions {
    my @options = ();
    foreach my $param ( keys %$configuration ) {
      if ( exists $configuration->{$param}->{'command_line_override'} ) {
        push @options,
            "-" . $configuration->{$param}->{'command_line_override'} . "=s";
      }
    }
    return @options;
  }

  #
  # Get POD documentation to add to the existing program POD stored in
  # the main script.
  #
  sub getPOD {
    my $pod_str;
    foreach my $param ( keys %$configuration ) {
      if ( exists $configuration->{$param}->{'command_line_override'} ) {
        $pod_str .= "=item -"
            . $configuration->{$param}->{'command_line_override'}
            . " <string>\n\n";
        $pod_str .= $configuration->{$param}->{'description'} . "\n\n";
      }
    }
    if ( $pod_str ) {
      return ( "\n=over 4\n\n" . $pod_str . "=back\n\n" );
    }
    return;
  }

  #
  # After GetOpt has filled in the options hash simply pass it to
  # this function to perform resolution.  The following precedence
  # is used:
  #
  #    1. Command Line Parameter
  #    2. Environment Variable
  #    3. Configuration File
  #
  # This will update the configuration{param}->{'value'} for use
  # in the main program.
  #
  sub resolveConfiguration {
    my $options = shift;

    foreach my $param ( keys %$configuration ) {
      if (
        exists $options->{ $configuration->{$param}->{'command_line_override'} }
          )
      {
        $configuration->{$param}->{'value'} =
            $options->{ $configuration->{$param}->{'command_line_override'} };
      }
      elsif (
             exists $ENV{ $configuration->{$param}->{'environment_override'} } )
      {
        $configuration->{$param}->{'value'} =
            $ENV{ $configuration->{$param}->{'environment_override'} };
      }
    }
  }

  sub getDependencyVersion {
    my $param = shift;

    if ( !exists $configuration->{$param} ) {
      die "Unknown parameter \"$param\"\n";
    }

    my $value = $configuration->{$param}->{'value'};
    my $version = "";
    my $tmpStr = "";
    if ( $param eq "RSCOUT_DIR" ) {
      # Simple case where the program reports it's version in it's usage details
      #./RepeatScout -blah
      #RepeatScout Version 1.0.6
      #
      #Usage:
      #RepeatScout -sequence <seq> -output <out> -freq <freq> -l <l> [opts]
      #     -L # size of region to extend left or right (10000)
      #     -match # reward for a match (+1)
      #     -mismatch # penalty for a mismatch (-1)
      #...
      $tmpStr = `$value/RepeatScout -blah 2>&1`;
      $tmpStr =~ /Version\s*(\d+\.\d+\.\d+)/;
      $version = $1;
    }elsif ( $param eq "RMBLAST_DIR" ) {
      #./rmblastn -version
      #rmblastn: 2.9.0+
      # Package: blast 2.9.0, build Sep  9 2019 15:21:42
      $tmpStr = `$value/rmblastn -version`;
      $tmpStr =~ /rmblastn:\s+(\d+\.\d+\.\d+\+?)/;
      $version = $1;
    }elsif ( $param eq "RECON_DIR" ) {
      # More complex.  The version is only printed in a
      # text file that may or may not have been installed by
      # the user.
      # 00README:
      # Version 1.08 (Jan 2014)
      if ( -e "$value/00README" ) {
        open IN,"<$value/00README" or die;
        while (<IN>){
          if (/Version\s+(\d+\.\d+)/ )
          {
            $version = $1;
            last;
          }
        }
        close IN;
      }
    }elsif ( $param eq "TRF_PRGM" ) {
      # trf -V
      # Tandem Repeats Finder, Version 4.09
      # Copyright (C) Dr. Gary Benson 1999-2012. All rights reserved.
      $tmpStr = `$value -V 2>&1`;
      $tmpStr =~ /Version\s+(\d+\.\d+)/;
      $version = $1;
    }elsif ( $param eq "ABBLAST_DIR" ) {
      #blastp -blah
      #BLASTP 3.0SE-AB [2009-10-30] [linux26-x64-I32LPF64 2009-10-30T17:06:09]
      $tmpStr = `$value/blastp -blah 2>&1`;
      $tmpStr =~ /BLASTP\s+(\d+\.\d+\S+)/;
      $version = $1;
    }elsif ( $param eq "CDHIT_DIR" ) {
      #cd-hit -blah
      # 	====== CD-HIT version 4.8.1 (built on Mar 21 2019) ======
      $tmpStr = `$value/cd-hit -blah 2>&1`;
      $tmpStr =~ /CD-HIT version\s+(\d+\.\d+\.\d+)/;
      $version = $1;
    }elsif ( $param eq "GENOMETOOLS_DIR" ) {
      #gt -version
      #/home/rhubley/src/genometools-1.5.9/bin/gt (GenomeTools) 1.5.9
      #Copyright (c) 2003-2016 G. Gremme, S. Steinbiss, S. Kurtz, and CONTRIBUTORS
      #Copyright (c) 2003-2016 Center for Bioinformatics, University of Hamburg
      #See LICENSE file or http://genometools.org/license.html for license details.
      #
      #Used compiler: cc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-36.0.1)
      #Compile flags:  -g -Wall -Wunused-parameter -pipe -fPIC -Wpointer-arith -Wno-unknown-pragmas -O3 -Werror
      $tmpStr = `$value/gt -version 2>&1`;
      $tmpStr =~ /\(GenomeTools\)\s+(\d+\.\d+\.\d+)/;
      $version = $1;
    }elsif ( $param eq "LTR_RETRIEVER_DIR" ) {
      # More complex.  Older versions only printed the version in the
      # output. This is fragile...but we are going to try and pull it
      # out of the script:
      open IN,"<$value/LTR_retriever" or die;
      while (<IN>){
        if (/^my\s+\$version\s*=\s*\"(\S+)\";/)
        {
          $version = $1;
          last;
        }
      }
      close IN;
    }elsif ( $param eq "MAFFT_DIR" ) {
      #mafft -blah
      #------------------------------------------------------------------------------
      #  MAFFT v7.407 (2018/Jul/23)
      #  https://mafft.cbrc.jp/alignment/software/
      #  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)
      #------------------------------------------------------------------------------
      $tmpStr = `$value/mafft -blah 2>&1`;
      $tmpStr =~ /MAFFT\s+v(\d+\.\d+)/;
      $version = $1;
    }elsif ( $param eq "NINJA_DIR" ) {
      #Ninja -v
      #Version 0.97-cluster_only
      $tmpStr = `$value/Ninja -v 2>&1`;
      $tmpStr =~ /Version\s+(\d+\.\d+\S+)/;
      $version = $1;
    }elsif ( $param eq "REPEATMASKER_DIR" ) {
      #RepeatMasker -v
      #RepeatMasker version 4.1.0
      $tmpStr = `$value/RepeatMasker -v 2>&1`;
      $tmpStr =~ /version\s+(\d+\.\d+\.\d+)/;
      $version = $1;
    }
    return $version;
  }

}

1;
