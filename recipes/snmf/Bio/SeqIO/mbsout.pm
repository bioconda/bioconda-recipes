# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::mbsout - input stream for output by Teshima et al.'s mbs. 

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

=head1 DESCRIPTION

mbs (Teshima KM, Innan H (2009) mbs: modifying Hudson's ms software to generate
samples of DNA sequences with a biallelic site under selection. BMC
Bioinformatics 10: 166 ) can be found at
http://www.biomedcentral.com/1471-2105/10/166/additional/.

Currently this object can be used to read output from mbs into seq objects.
However, because bioperl has no support for haplotypes created using an infinite
sites model (where '1' identifies a derived allele and '0' identifies an
ancestral allele), the sequences returned by mbsout are coded using A, T, C and
G. To decode the bases, use the sequence conversion table (a hash) returned by
get_base_conversion_table(). In the table, 4 and 5 are used when the ancestry is
unclear. This should not ever happen when creating files with mbs, but it will 
be used when creating mbsOUT files from a collection of seq objects ( To be 
added later ). Alternatively, use get_next_hap() to get a string with 1's and 
0's instead of a seq object.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to the
Bioperl mailing list. Your participation is much appreciated. 

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs 

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via the
web:

  https://github.com/bioperl/bioperl-live/issues  

=head1 AUTHOR - Warren Kretzschmar

This module was written by Warren Kretzschmar

email: wkretzsch@gmail.com

This module grew out of a parser written by Aida Andres.

=head1 COPYRIGHT

=head2 Public Domain Notice

This software/database is ``United States Government Work'' under the
terms of the United States Copyright Act. It was written as part of
the authors' official duties for the United States Government and thus
cannot be copyrighted. This software/database is freely available to
the public for use without a copyright notice. Restrictions cannot
be placed on its present or future use.

Although all reasonable efforts have been taken to ensure the accuracy
and reliability of the software and data, the National Human Genome
Research Institute (NHGRI) and the U.S. Government does not and cannot
warrant the performance or results that may be obtained by using this
software or data.  NHGRI and the U.S. Government disclaims all
warranties as to performance, merchantability or fitness for any
particular purpose.

=head1 METHODS

=cut

package Bio::SeqIO::mbsout;

use version;
our $API_VERSION = qv('1.1.3');

use strict;
use base qw(Bio::SeqIO);    # This ISA Bio::SeqIO object
use Bio::Seq::SeqFactory;

=head2 INTERNAL METHODS

=head3 _initialize

Title   : _initialize
Usage   : $stream = Bio::SeqIO::mbsout->new($infile)
Function: extracts basic information about the file.
Returns : Bio::SeqIO object
Args    : no_og
Details	: include 'no_og' flag = 0 if the last population of an mbsout file 
          contains only one haplotype and you want the last haplotype to be 
          treated as the outgroup.
=cut

sub _initialize {
    my ( $self, @args ) = @_;
    $self->SUPER::_initialize(@args);

    unless ( defined $self->sequence_factory ) {
        $self->sequence_factory( Bio::Seq::SeqFactory->new() );
    }

    # Don't expect mbs to create an outgroup
    my ($no_og) = $self->_rearrange( [qw(NO_OG)], @args ) || 1;

    my %initial_values = (
        RUNS              => undef,
        SEGSITES          => undef,
        MBS_INFO_LINE     => undef,
        TOT_RUN_HAPS      => undef,
        NEXT_RUN_NUM      => undef, # What run is the next hap from? undef = EOF
        LAST_READ_HAP_NUM => undef, # What did we just read from
        LAST_READ_POSITIONS                      => [],
        LAST_READ_SEGSITES                       => undef,
        BUFFER_HAP                               => undef,
        NO_OUTGROUP                              => $no_og,
        OPTIONS                                  => {},
        LAST_READ_ALLELES                        => [],
        LAST_READ_TRAJECTORY_FILE                => undef,
        LAST_READ_REPLICATION_OF_TRAJECTORY_FILE => undef,
        BASE_CONVERSION_TABLE_HASH_REF           => {
            'A' => 0,
            'T' => 1,
            'C' => 4,
            'G' => 5,
        },
    );

    foreach my $key ( keys %initial_values ) {
        $self->{$key} = $initial_values{$key};
    }

    # If the filehandle is defined open it and read a few lines
    if ( ref( $self->{_filehandle} ) eq 'GLOB' ) {
        $self->_read_start();
        return $self;
    }

    # Otherwise throw a warning
    else {
        $self->throw(
"No filehandle defined.  Please define a file handle through -file when calling mbsout with Bio::SeqIO"
        );
    }
}

=head3 _read_start

Title   : _read_start
Usage   : $stream->_read_start()
Function: reads from the filehandle $stream->{_filehandle} all information up to the first haplotype (sequence). 
Returns : void
Args    : none

=cut

sub _read_start {
    my $self = shift;

    my $fh_IN = $self->{_filehandle};

    # get the first five lines and parse for important info
    my ($mbs_info_line) = $self->_get_next_clean_hap( $fh_IN, 1, 1 );

    my @mbs_info_line = split( /\s+/, $mbs_info_line );

    # Parsing the mbs header line
    shift @mbs_info_line;
    shift @mbs_info_line;
    my $tot_run_haps = shift @mbs_info_line;
    my $runs;

    # $pop_mut_param_per_site is the population mutation parameter per site.
    my $pop_mut_param_per_site;

    # $pop_recomb_param_per_site is the population recombination parameter per
    # site.
    my $pop_recomb_param_per_site;

    # $nsites is length of the simulated region.
    # $selpos is position of the target site of selection relative to the first
    # site of the simulated region.
    my $nsites;
    my $selpos;

    # $nfile is number of trajectory files.
    # $nrep is number of replications for each trajectory.
    # $traj_filename is initial part of the name of the trajectory files.
    my $nfiles;
    my $nreps;
    my $traj_filename;

    foreach my $word ( 0 .. $#mbs_info_line ) {
        if ( $mbs_info_line[$word] eq '-t' ) {
            $pop_mut_param_per_site = $mbs_info_line[ $word + 1 ];
        }
        elsif ( $mbs_info_line[$word] eq '-r' ) {
            $pop_recomb_param_per_site = $mbs_info_line[ $word + 1 ];
            $selpos                    = $mbs_info_line[ $word + 2 ];
        }
        elsif ( $mbs_info_line[$word] eq '-s' ) {
            $nsites = $mbs_info_line[ $word + 1 ];
            $selpos = $mbs_info_line[ $word + 2 ];
        }
        elsif ( $mbs_info_line[$word] eq '-f' ) {
            $nfiles        = $mbs_info_line[ $word + 1 ];
            $nreps         = $mbs_info_line[ $word + 2 ];
            $traj_filename = $mbs_info_line[ $word + 3 ];
            $runs          = $nfiles * $nreps;
        }
        else { next; }
    }

    # Save mbs info data
    $self->{RUNS}                      = $runs;
    $self->{MBS_INFO_LINE}             = $mbs_info_line;
    $self->{TOT_RUN_HAPS}              = $tot_run_haps;
    $self->{POP_MUT_PARAM_PER_SITE}    = $pop_mut_param_per_site;
    $self->{POP_RECOMB_PARAM_PER_SITE} = $pop_recomb_param_per_site;
    $self->{NSITES}                    = $nsites;
    $self->{SELPOS}                    = $selpos;
    $self->{NFILES}                    = $nfiles;
    $self->{NREPS}                     = $nreps;
    $self->{TRAJ_FILENAME}             = $traj_filename;
}

=head2 Methods to retrieve mbsout data	        

=head3 get_segsites

Title   : get_segsites
Usage   : $segsites = $stream->get_segsites()
Function: returns the number segsites in the mbsout file (according to the mbsout header line).
Returns : scalar
Args    : NONE

=cut

sub get_segsites {
    my $self = shift;
    if ( defined $self->{SEGSITES} ) {
        return $self->{SEGSITES};
    }
    else {
        return $self->get_current_run_segsites;
    }
}

=head3 get_current_run_segsites

Title   : get_current_run_segsites
Usage   : $segsites = $stream->get_current_run_segsites()
Function: returns the number of segsites in the run of the last read haplotype (sequence).
Returns : scalar
Args    : NONE

=cut

sub get_current_run_segsites {
    my $self = shift;
    return $self->{LAST_READ_SEGSITES};
}

=head3 get_pop_mut_param_per_site

Title   : get_pop_mut_param_per_site
Usage   : $pop_mut_param_per_site = $stream->get_pop_mut_param_per_site()
Function: returns 4*N0*mu or the "population mutation parameter per site"
Returns : scalar
Args    : NONE

=cut

sub get_pop_mut_param_per_site {
    my $self = shift;
    return $self->{POP_MUT_PARAM_PER_SITE};
}

=head3 get_pop_recomb_param_per_site

Title   : get_pop_recomb_param_per_site
Usage   : $pop_recomb_param_per_site = $stream->get_pop_recomb_param_per_site()
Function: returns 4*N0*r or the "population recombination parameter per site"
Returns : scalar
Args    : NONE

=cut

sub get_pop_recomb_param_per_site {
    my $self = shift;
    return $self->{POP_RECOMB_PARAM_PER_SITE};
}

=head3 get_nsites

Title   : get_nsites
Usage   : $nsites = $stream->get_nsites()
Function: returns the number of sites simulated by mbs.
Returns : scalar
Args    : NONE

=cut

sub get_nsites {
    my $self = shift;
    return $self->{NSITES};
}

=head3 get_selpos

Title   : get_selpos
Usage   : $selpos = $stream->get_selpos()
Function: returns the location on the chromosome where the allele is located that was selected for by mbs.
Returns : scalar
Args    : NONE

=cut

sub get_selpos {
    my $self = shift;
    return $self->{SELPOS};
}

=head3 get_nreps

Title   : get_nreps
Usage   : $nreps = $stream->get_nreps()
Function: returns the number replications done by mbs on each trajectory file to create the mbsout file.
Returns : scalar
Args    : NONE

=cut

sub get_nreps {
    my $self = shift;
    return $self->{NREPS};
}

=head3 get_nfiles

Title   : get_nfiles
Usage   : $nfiles = $stream->get_nfiles()
Function: returns the number of trajectory files used by mbs to create the mbsout file
Returns : scalar
Args    : NONE

=cut

sub get_nfiles {
    my $self = shift;
    return $self->{NFILES};
}

=head3 get_traj_filename

Title   : get_traj_filename
Usage   : $traj_filename = $stream->get_traj_filename()
Function: returns the prefix of the trajectory files used by mbs to create the mbsout file
Returns : scalar
Args    : NONE

=cut

sub get_traj_filename {
    my $self = shift;
    return $self->{TRAJ_FILENAME};
}

=head3 get_runs

Title   : get_runs
Usage   : $runs = $stream->get_runs()
Function: returns the number of runs in the mbsout file
Returns : scalar
Args    : NONE

=cut

sub get_runs {
    my $self = shift;
    return $self->{RUNS};
}

=head3 get_Positions

Title   : get_Positions
Usage   : @positions = $stream->get_Positions()
Function: returns an array of the names of each segsite of the run of the last read hap.
Returns : array
Args    : NONE

=cut

sub get_Positions {
    my $self = shift;
    return @{ $self->{LAST_READ_POSITIONS} };
}

=head3 get_tot_run_haps

Title   : get_tot_run_haps
Usage   : $number_of_haps_per_run = $stream->get_tot_run_haps()
Function: returns the number of haplotypes (sequences) in each run of the mbsout file.
Returns : scalar >= 0
Args    : NONE

=cut

sub get_tot_run_haps {
    my $self = shift;
    return $self->{TOT_RUN_HAPS};
}

=head3 get_mbs_info_line

Title   : get_mbs_info_line
Usage   : $mbs_info_line = $stream->get_mbs_info_line()
Function: returns the header line of the mbsout file.
Returns : scalar
Args    : NONE

=cut

sub get_mbs_info_line {
    my $self = shift;
    return $self->{MBS_INFO_LINE};
}

=head3 tot_haps

Title   : tot_haps
Usage   : $number_of_haplotypes_in_file = $stream->tot_haps()
Function: returns the number of haplotypes (sequences) in the mbsout file.  Information gathered from mbsout header line.
Returns : scalar
Args    : NONE

=cut

sub get_tot_haps {
    my $self = shift;
    return ( $self->{TOT_RUN_HAPS} * $self->{RUNS} );
}

=head3 next_run_num

Title   : next_run_num
Usage   : $next_run_number = $stream->next_run_num()
Function: returns the number of the mbs run that the next haplotype (sequence) 
          will be taken from (starting at 1).  Returns undef if the complete 
          file has been read.
Returns : scalar > 0 or undef
Args    : NONE

=cut

sub get_next_run_num {
    my $self = shift;
    return $self->{NEXT_RUN_NUM};
}

=head3 get_last_haps_run_num

Title   : get_last_haps_run_num
Usage   : $last_haps_run_number = $stream->get_last_haps_run_num()
Function: returns the number of the ms run that the last haplotype (sequence)
          was taken from (starting at 1).  Returns undef if no hap has been
          read yet.
Returns : scalar > 0 or undef
Args    : NONE

=cut

sub get_last_haps_run_num {
    my $self = shift;
    return $self->{LAST_HAPS_RUN_NUM};
}

=head3 get_last_read_hap_num

Title   : get_last_read_hap_num
Usage   : $last_read_hap_num = $stream->get_last_read_hap_num()
          Function: returns the number (starting with 1) of the last haplotype 
          read from the mbs file
Returns : scalar >= 0
Args    : NONE
Details	: 0 means that no haplotype has been read yet.

=cut

sub get_last_read_hap_num {
    my $self = shift;
    return $self->{LAST_READ_HAP_NUM};
}

=head3 outgroup

Title   : outgroup
Usage   : $outgroup = $stream->outgroup()
Function: returns '1' if the mbsout object has an outgroup.  Returns '0' 
          otherwise.
Returns :  1 or 0, currently always 0
Args    : NONE
Details	: This method will return '1' only if the last population in the mbsout 
          file contains only one haplotype.  If the last population is not an 
          outgroup then create the mbsout object using 'no_outgroup' as input 
          parameter for new() (see mbsout->new()). 

          Currently there exists no way of introducing an outgroup into an mbs 
          file, so this function will always return '0'.

=cut

sub outgroup {
    my $self = shift;
    if   ( $self->{NO_OUTGROUP} ) { return 0; }
    else                          { return 0; }
}

=head3 get_next_seq

Title   : get_next_seq
Usage   : $seq = $stream->get_next_seq()
Function: reads and returns the next sequence (haplotype) in the stream
Returns : Bio::Seq object
Args    : NONE
Note	: This function is included only to conform to convention.  It only 
          calls next_hap() and passes on that method's return value.  Use 
          next_hap() instead for better performance.

=cut

sub get_next_seq {
    my $self      = shift;
    my $seqstring = $self->get_next_hap;

    return unless defined $seqstring;

    # Used to create unique ID;
    my $run = $self->get_last_haps_run_num;

    # Converting numbers to letters so that the haplotypes can be stored as a
    # seq object
    my $rh_base_conversion_table = $self->get_base_conversion_table;
    foreach my $base ( keys %{$rh_base_conversion_table} ) {
        $seqstring =~ s/($rh_base_conversion_table->{$base})/$base/g;
    }

    my $last_read_hap = $self->get_last_read_hap_num;

    my $id = 'Hap_' . $last_read_hap . '_Run_' . $run;
    my $description =
        'Segsites '
      . $self->get_current_run_segsites
      . "; Positions $self->positions; Haplotype "
      . $last_read_hap
      . '; Run '
      . $run . ';';
    my $seq = $self->sequence_factory->create(
        -seq      => $seqstring,
        -id       => $id,
        -desc     => $description,
        -alphabet => q(dna),
        -direct   => 1,
    );

    return $seq;

}

=head3 get_next_hap

Title   : get_next_hap
Usage   : $seq = $stream->get_next_hap()
Function: reads and returns the next sequence (haplotype) in the stream. Returns 
          void if all sequences in stream have been read.
Returns : Bio::Seq object
Args    : NONE
Note	: Use this instead of get_next_seq().  

=cut

sub get_next_hap {
    my $self = shift;

    # Let's figure out how many haps to read from the input file so that
    # we get back to the beginning of the next run.

    my $end_run = 0;
    if ( $self->{TOT_RUN_HAPS} == $self->{LAST_READ_HAP_NUM} + 1 ) {
        $end_run = 1;
    }

    # Setting last_haps_run_num
    $self->{LAST_HAPS_RUN_NUM} = $self->get_next_run_num;

    my $fh_IN = $self->{_filehandle};

    my ($seqstring) =
      $self->_get_next_clean_hap( $self->{_filehandle}, 1, $end_run );

    return $seqstring;
}

=head3 get_next_run

Title   : get_next_run
Usage   : @seqs = $stream->get_next_run()
Function: reads and returns all the remaining sequences (haplotypes) in the mbs 
          run of the next sequence.  
Returns : array of Bio::Seq objects
Args    : NONE  

=cut

sub get_next_run {
    my $self = shift;

    # Let's figure out how many haps to read from the input file so that
    # we get back to the beginning of the next run.

    my $haps_to_pull = $self->{TOT_RUN_HAPS} - $self->{LAST_READ_HAP_NUM};

    # Read those haps from the input file
    # Next hap read will be the first hap of the next run.

    my @seqs;
    for ( 1 .. $haps_to_pull ) {
        my $seq = $self->get_next_seq;
        next unless defined $seq;

        push @seqs, $seq;
    }

    return @seqs;
}

=head2 METHODS TO RETRIEVE CONSTANTS

=head3 base_conversion_table

Title   : get_base_conversion_table
Usage   : $table_hash_ref = $stream->get_base_conversion_table()
Function: returns a reference to a hash.  The keys of the hash are the letters 
          'A','T','G','C'.  The values associated with each key are the value 
          that each letter in the sequence of a seq object returned by a 
          Bio::SeqIO::mbsout stream should be translated to.
Returns : reference to a hash
Args    : NONE  
Synopsys:
	
	# retrieve the Bio::Seq object's sequence
	my $haplotype = $seq->seq;
	my $rh_base_conversion_table = $stream->get_base_conversion_table();
	
	# need to convert all letters to their corresponding numbers.
	foreach my $base (keys %{$rh_base_conversion_table}){
		$haplotype =~ s/($base)/$rh_base_conversion_table->{$base}/g;
	}
	
	# $haplotype is now an ms style haplotype. (e.g. '100101101455')
	
=cut

sub get_base_conversion_table {
    my $self = shift;
    return $self->{BASE_CONVERSION_TABLE_HASH_REF};
}

##############################################################################
## subs for internal use only
##############################################################################

sub _get_next_clean_hap {

    #By Warren Kretzschmar

    # return the next non-empty line from file handle (chomped line)
    # skipps to the next run if '//' is encountered
    my ( $self, $fh, $times, $end_run ) = @_;
    my @data;

    unless ( defined $fh ) { return; }

    unless ( defined $times && $times > 0 ) {
        $times = 1;
    }

    if ( defined $self->{BUFFER_HAP} ) {
        push @data, $self->{BUFFER_HAP};
        $self->{BUFFER_HAP} = undef;
        $self->{LAST_READ_HAP_NUM}++;
        $times--;
    }

    while ( 1 <= $times-- ) {

        # Find next clean line
        my $data = <$fh>;
        last if !defined($data);
        chomp $data;
        while ( $data !~ /./ ) {
            $data = <$fh>;
            chomp $data;
        }

        # If the next run is encountered here, then we have a programming
        # or format error
        if ( $data eq '//' ) { $self->throw("'//' found when not expected\n") }

        $self->{LAST_READ_HAP_NUM}++;
        push @data, $data;
    }

    if ($end_run) {
        $self->_load_run_info($fh);
    }

    return (@data);
}

sub _load_run_info {

    my ( $self, $fh ) = @_;

    my $data = <$fh>;

    # In this case we are at EOF
    if ( !defined($data) ) { $self->{NEXT_RUN_NUM} = undef; return; }

    chomp $data;

    while ( $data !~ /./ ) {
        $data = <$fh>;

        # In this case we are at EOF
        if ( !defined($data) ) { $self->{NEXT_RUN_NUM} = undef; return; }
        chomp $data;
    }

    # If the next run is encountered, then skip to the next hap and save it in
    # the buffer.
    if ( $data =~ /^\/\// ) {
        $self->{NEXT_RUN_NUM}++;
        $self->{LAST_READ_HAP_NUM} = 0;
        my @data = split( /\s+/,  $data );
        my @temp = split( /\/\//, $data[0] );
        @temp = split( /-/, $temp[0] );
        $self->{LAST_READ_TRAJ_FILE}             = $temp[0];
        $self->{LAST_LEAD_TRAJ_FILE_REPLICATION} = $temp[1];
        $self->{LAST_READ_ALLELES}               = \@data[ 2 .. $#data ];

        for ( 1 .. 3 ) {
            $data = <$fh>;
            while ( $data !~ /./ ) {
                $data = <$fh>;
            }
            chomp $data;

            @data = split( /\s+/, $data );

            if ( $_ eq '1' ) {
                $self->{LAST_READ_SEGSITES} = $data[1];
            }
            elsif ( $_ eq '2' ) {
                $self->{LAST_READ_POSITIONS} = [ @data[ 1 .. $#data ] ];
            }
            else {
                if ( !defined($data) ) {
                    $self->throw("run $self->{NEXT_RUN_NUM} has no haps./n");
                }
                $self->{BUFFER_HAP} = $data;
            }
        }
    }
    else { $self->throw("'//' not encountered when expected\n") }

}
1;
