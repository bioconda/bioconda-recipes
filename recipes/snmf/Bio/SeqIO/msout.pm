# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::msout - input stream for output by Hudson's ms 

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

=head1 DESCRIPTION

ms ( Hudson, R. R. (2002) Generating samples under a Wright-Fisher neutral
model. Bioinformatics 18:337-8 ) can be found at
http://home.uchicago.edu/~rhudson1/source/mksamples.html.

Currently, this object can be used to read output from ms into seq objects.
However, because bioperl has no support for haplotypes created using an infinite
sites model (where '1' identifies a derived allele and '0' identifies an
ancestral allele), the sequences returned by msout are coded using A, T, C and
G. To decode the bases, use the sequence conversion table (a hash) returned by
get_base_conversion_table(). In the table, 4 and 5 are used when the ancestry is
unclear. This should not ever happen when creating files with ms, but it will be
used when creating msOUT files from a collection of seq objects ( To be added
later ). Alternatively, use get_next_hap() to get a string with 1's and 0's
instead of a seq object.

=head2 Mapping to Finite Sites

This object can now also be used to map haplotypes created using an infinite sites
model to sequences of arbitrary finite length.  See set_n_sites() for more detail.
Thanks to Filipe G. Vieira <fgvieira@berkeley.edu> for the idea and code.

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

package Bio::SeqIO::msout;
use version;
our $API_VERSION = qv('1.1.8');

use strict;
use base qw(Bio::SeqIO);    # This ISA Bio::SeqIO object
use Bio::Seq::SeqFactory;

=head2 Methods for Internal Use

=head3 _initialize

Title   : _initialize
Usage   : $stream = Bio::SeqIO::msOUT->new($infile)
Function: extracts basic information about the file.
Returns : Bio::SeqIO object
Args    : no_og, gunzip, gzip, n_sites
Details	: 
    - include 'no_og' flag if the last population of an msout file contains
      only one haplotype and you don't want the last haplotype to be
      treated as the outgroup ( suggested when reading data created by ms ).
    - including 'n_sites' (positive integer) causes all output haplotypes to be
      mapped to a sequence of length 'n_sites'. See set_n_sites() for more details.

=cut

sub _initialize {
    my ( $self, @args ) = @_;
    $self->SUPER::_initialize(@args);

    unless ( defined $self->sequence_factory ) {
        $self->sequence_factory( Bio::Seq::SeqFactory->new() );
    }
    my ($no_og)   = $self->_rearrange( [qw(NO_OG)],   @args );
    my ($n_sites) = $self->_rearrange( [qw(N_SITES)], @args );

    my %initial_values = (
        RUNS              => undef,
        N_SITES           => undef,
        SEGSITES          => undef,
        SEEDS             => [],
        MS_INFO_LINE      => undef,
        TOT_RUN_HAPS      => undef,
        POPS              => [],
        NEXT_RUN_NUM      => undef, # What run is the next hap from? undef = EOF
        LAST_READ_HAP_NUM => undef, # What did we just read from
        LAST_HAPS_RUN_NUM => undef,
        LAST_READ_POSITIONS            => [],
        LAST_READ_SEGSITES             => undef,
        BUFFER_HAP                     => undef,
        NO_OUTGROUP                    => $no_og,
        BASE_CONVERSION_TABLE_HASH_REF => {
            'A' => 0,
            'T' => 1,
            'C' => 4,
            'G' => 5,
        },
    );
    foreach my $key ( keys %initial_values ) {
        $self->{$key} = $initial_values{$key};
    }
    $self->set_n_sites($n_sites);

    # If the filehandle is defined open it and read a few lines
    if ( ref( $self->{_filehandle} ) eq 'GLOB' ) {
        $self->_read_start();
        return $self;
    }

    # Otherwise throw a warning
    else {
        $self->throw(
"No filehandle defined.  Please define a file handle through -file when calling msout with Bio::SeqIO"
        );
    }
}

=head3 _read_start

Title   : _read_start
Usage   : $stream->_read_start()
Function: reads from the filehandle $stream->{_filehandle} all information up to the first haplotype (sequence).  Closes the filehandle if all lines have been read.  
Returns : void
Args    : none

=cut

sub _read_start {
    my $self = shift;

    my $fh_IN = $self->{_filehandle};

    # get the first five lines and parse for important info
    my ( $ms_info_line, $seeds ) = $self->_get_next_clean_hap( $fh_IN, 2, 1 );

    my @ms_info_line = split( /\s+/, $ms_info_line );

    my ( $tot_pops, @pop_haplos );

    # Parsing the ms header line
    shift @ms_info_line;
    my $tot_run_haps = shift @ms_info_line;
    my $runs         = shift @ms_info_line;
    my $segsites;

    foreach my $word ( 0 .. $#ms_info_line ) {
        if ( $ms_info_line[$word] eq '-I' ) {
            $tot_pops = $ms_info_line[ $word + 1 ];
            for my $pop_num ( 1 .. $tot_pops ) {
                push @pop_haplos, $ms_info_line[ $word + 1 + $pop_num ];
            }

# if @pop_haplos contains a non-digit, then there is an error in the msinfo line.
            if ( !defined $pop_haplos[-1] || $pop_haplos[-1] =~ /\D/ ) {
                $self->throw(
"Incorrect number of populations in the ms info line (after the -I specifier)"
                );
            }
        }
        elsif ( $ms_info_line[$word] eq '-s' ) {
            $segsites = $ms_info_line[ $word + 1 ];
        }
        else { next; }
    }

    unless (@pop_haplos) { @pop_haplos = ($tot_run_haps) }

    my @seeds = split( /\s+/, $seeds );

    # Save ms info data
    $self->{RUNS}         = $runs;
    $self->{SEGSITES}     = $segsites;
    $self->{SEEDS}        = \@seeds;
    $self->{MS_INFO_LINE} = $ms_info_line;
    $self->{TOT_RUN_HAPS} = $tot_run_haps;
    $self->{POPS}         = [@pop_haplos];

    return;
}

=head2 Methods to Access Data

=head3 get_segsites

Title   : get_segsites
Usage   : $segsites = $stream->get_segsites()
Function: returns the number of segsites in the msOUT file (according to the msOUT header line's -s option), or the current run's segsites if -s was not specified in the command line (in this case the number of segsites varies from run to run). 
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
Function: returns the number of segsites in the run of the last read
          haplotype (sequence).
Returns : scalar
Args    : NONE

=cut

sub get_current_run_segsites {
    my $self = shift;
    return $self->{LAST_READ_SEGSITES};
}

=head3 get_n_sites

Title   : get_n_sites
Usage   : $n_sites = $stream->get_n_sites()
Function: Gets the number of total sites (variable or not) to be output.
Returns : scalar if n_sites option is defined at call time of new()
Args    : NONE
Note    :
          WARNING: Final sequence length might not be equal to n_sites if n_sites is
                   too close to number of segregating sites in the msout file.

=cut

sub get_n_sites {
    my ($self) = @_;

    return $self->{N_SITES};
}

=head3 set_n_sites

Title   : set_n_sites
Usage   : $n_sites = $stream->set_n_sites($value)
Function: Sets the number of total sites (variable or not) to be output.
Returns : 1 on success; throws an error if $value is not a positive integer or undef
Args    : positive integer
Note    :
          WARNING: Final sequence length might not be equal to n_sites if it is 
                   too close to number of segregating sites.
          - n_sites needs to be at least as large as the number of segsites of 
            the next haplotype returned
          - n_sites may also be set to undef, in which case haplotypes are returned 
            under the infinite sites model assumptions.

=cut

sub set_n_sites {
    my ( $self, $value ) = @_;

    # make sure $value is a positive integer if it is defined
    if ( defined $value ) {
        $self->throw(
"first argument needs to be a positive integer. argument supplied: $value"
        ) unless ( $value =~ m/^\d+$/ && $value > 0 );
    }
    $self->{N_SITES} = $value;

    return 1;
}

=head3 get_runs

Title   : get_runs
Usage   : $runs = $stream->get_runs()
Function: returns the number of runs in the msOUT file (according to the
          msinfo line)
Returns : scalar
Args    : NONE

=cut

sub get_runs {
    my $self = shift;
    return $self->{RUNS};
}

=head3 get_Seeds

Title   : get_Seeds
Usage   : @seeds = $stream->get_Seeds()
Function: returns an array of the seeds used in the creation of the msOUT file.
Returns : array
Args    : NONE
Details : In older versions, ms used three seeds.  Newer versions of ms seem to
          use only one (longer) seed.  This function will return all the seeds
          found.

=cut

sub get_Seeds {
    my $self = shift;
    return @{ $self->{SEEDS} };
}

=head3 get_Positions

Title   : get_Positions
Usage   : @positions = $stream->get_Positions()
Function: returns an array of the names of each segsite of the run of the last
          read hap.
Returns : array
Args    : NONE
Details : The Positions may or may not vary from run to run depending on the
          options used with ms.

=cut

sub get_Positions {
    my $self = shift;
    return @{ $self->{LAST_READ_POSITIONS} };
}

=head3 get_tot_run_haps

Title   : get_tot_run_haps
Usage   : $number_of_haps_per_run = $stream->get_tot_run_haps()
Function: returns the number of haplotypes (sequences) in each run of the msOUT
          file ( according to the msinfo line ).
Returns : scalar >= 0
Args    : NONE
Details : This number should not vary from run to run.

=cut

sub get_tot_run_haps {
    my $self = shift;
    return $self->{TOT_RUN_HAPS};
}

=head3 get_ms_info_line

Title   : get_ms_info_line
Usage   : $ms_info_line = $stream->get_ms_info_line()
Function: returns the header line of the msOUT file.
Returns : scalar
Args    : NONE

=cut

sub get_ms_info_line {
    my $self = shift;
    return $self->{MS_INFO_LINE};
}

=head3 tot_haps

Title   : tot_haps
Usage   : $number_of_haplotypes_in_file = $stream->tot_haps()
Function: returns the number of haplotypes (sequences) in the msOUT file.
          Information gathered from msOUT header line.
Returns : scalar
Args    : NONE

=cut

sub get_tot_haps {
    my $self = shift;
    return ( $self->{TOT_RUN_HAPS} * $self->{RUNS} );
}

=head3 get_Pops

Title   : get_Pops
Usage   : @pops = $stream->pops()
Function: returns an array of population sizes (order taken from the -I flag in
          the msOUT header line).  This array will include the last hap even if
          it looks like an outgroup.
Returns : array of scalars > 0
Args    : NONE

=cut

sub get_Pops {
    my $self = shift;
    return @{ $self->{POPS} };
}

=head3 get_next_run_num

Title   : get_next_run_num
Usage   : $next_run_number = $stream->next_run_num()
Function: returns the number of the ms run that the next haplotype (sequence)
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
Function: returns the number (starting with 1) of the last haplotype read from
          the ms file
Returns : scalar >= 0
Args    : NONE
Details	: 0 means that no haplotype has been read yet.  Is reset to 0 every run.

=cut

sub get_last_read_hap_num {
    my $self = shift;
    return $self->{LAST_READ_HAP_NUM};
}

=head3 outgroup

Title   : outgroup
Usage   : $outgroup = $stream->outgroup()
Function: returns '1' if the msOUT stream has an outgroup.  Returns '0'
          otherwise.
Returns : '1' or '0'
Args    : NONE
Details	: This method will return '1' only if the last population in the msOUT
          file contains only one haplotype.  If the last population is not an
          outgroup then create the msOUT object using 'no_og' as input flag.
          Also, return 0, if the run has only one population.

=cut

sub outgroup {
    my $self = shift;
    my @pops = $self->get_Pops;
    if ( $pops[$#pops] == 1 && !defined $self->{NO_OUTGROUP} && @pops > 1 ) {
        return 1;
    }
    else { return 0; }
}

=head3 get_next_haps_pop_num

Title   : get_next_haps_pop_num
Usage   : ($next_haps_pop_num, $num_haps_left_in_pop) = $stream->get_next_haps_pop_num()
Function: First return value is the population number (starting with 1) the
          next hap will come from. The second return value is the number of haps
          left to read in the population from which the next hap will come.
Returns : (scalar > 0, scalar > 0)
Args    : NONE

=cut

sub get_next_haps_pop_num {
    my $self          = shift;
    my $last_read_hap = $self->get_last_read_hap_num;
    my @pops          = $self->get_Pops;

    foreach my $pop_num ( 0 .. $#pops ) {
        if ( $last_read_hap < $pops[$pop_num] ) {
            return ( $pop_num + 1, $pops[$pop_num] - $last_read_hap );
        }
        else { $last_read_hap -= $pops[$pop_num] }
    }

    # In this case we're at the beginning of the next run
    return ( 1, $pops[0] );
}

=head3 get_next_seq

Title   : get_next_seq
Usage   : $seq = $stream->get_next_seq()
Function: reads and returns the next sequence (haplotype) in the stream
Returns : Bio::Seq object or void if end of file
Args    : NONE
Note	: This function is included only to conform to convention.  The
          returned Bio::Seq object holds a halpotype in coded form. Use the hash
          returned by get_base_conversion_table() to convert 'A', 'T', 'C', 'G'
          back into 1,2,4 and 5. Use get_next_hap() to retrieve the halptoype as
          a string of 1,2,4 and 5s instead.

=cut

sub get_next_seq {
    my $self      = shift;
    my $seqstring = $self->get_next_hap;

    return unless ($seqstring);

    # Used to create unique ID;
    my $run = $self->get_last_haps_run_num;

    # Converting numbers to letters so that the haplotypes can be stored as a
    # seq object
    my $rh_base_conversion_table = $self->get_base_conversion_table;
    foreach my $base ( keys %{$rh_base_conversion_table} ) {
        $seqstring =~ s/($rh_base_conversion_table->{$base})/$base/g;
    }

    # Fill in non-variable positions
    my $segsites = $self->get_current_run_segsites;
    my $n_sites  = $self->get_n_sites;
    if ( defined($n_sites) ) {

        # make sure that n_sites is at least as large
        # as segsites for each run. Throw an exception otherwise.
        $self->throw( "n_sites:\t$n_sites"
              . "\nsegsites:\t$segsites"
              . "\nrun:\t$run"
              . "\nn_sites needs to be at least the number of segsites of every run"
        ) unless $segsites <= $n_sites;

        my $seq_len = 0;
        my @seq;
        my @pos = $self->get_Positions;
        for ( my $i = 0 ; $i <= $#pos ; $i++ ) {
            $pos[$i] *= $n_sites;
            push( @seq, "A" x ( $pos[$i] - 1 - $seq_len ) );
            $seq_len += length( $seq[-1] );
            push( @seq, substr( $seqstring, $i, 1 ) );
            $seq_len += length( $seq[-1] );
        }
        push( @seq, "A" x ( $n_sites - $seq_len ) );
        $seqstring = join( "", @seq );
    }

    my $last_read_hap = $self->get_last_read_hap_num;
    my $id            = 'Hap_' . $last_read_hap . '_Run_' . $run;
    my $description =
        "Segsites $segsites;"
      . " Positions "
      . ( defined $n_sites ? $n_sites : $segsites ) . ";"
      . " Haplotype $last_read_hap;"
      . " Run $run;";
    my $seq = $self->sequence_factory->create(
        -seq      => $seqstring,
        -id       => $id,
        -desc     => $description,
        -alphabet => q(dna),
        -direct   => 1,
    );

    return $seq

}

=head3 next_seq

Title   : next_seq
Usage   : $seq = $stream->next_seq()
Function: Alias to get_next_seq()
Returns : Bio::Seq object or void if end of file
Args    : NONE
Note    : This function is only included for convention.  It calls get_next_seq().  
          See get_next_seq() for details.

=cut

sub next_seq {
    my $self = shift;
    return $self->get_next_seq();
}

=head3 get_next_hap

Title   : get_next_hap
Usage   : $hap = $stream->next_hap()
Function: reads and returns the next sequence (haplotype) in the stream.
          Returns undef if all sequences in stream have been read.
Returns : Haplotype string (e.g. '110110000101101045454000101'
Args    : NONE
Note	: Use get_next_seq() if you want the halpotype returned as a
          Bio::Seq object.  

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

    my $last_read_hap = $self->get_last_read_hap_num;
    my ($seqstring) =
      $self->_get_next_clean_hap( $self->{_filehandle}, 1, $end_run );
    if ( !defined $seqstring && $last_read_hap < $self->get_tot_haps ) {
        $self->throw(
"msout file has only $last_read_hap hap(s), which is less than indicated in msinfo line ( "
              . $self->get_tot_haps
              . " )" );
    }

    return $seqstring;
}

=head3 get_next_pop

Title   : get_next_pop
Usage   : @seqs = $stream->next_pop()
Function: reads and returns all the remaining sequences (haplotypes) in the
          population of the next sequence.  Returns an empty list if no more 
          haps remain to be read in the stream  
Returns : array of Bio::Seq objects
Args    : NONE  

=cut

sub get_next_pop {
    my $self = shift;

    # Let's figure out how many haps to read from the input file so that
    # we get back to the beginning of the next run.

    my @pops = $self->get_Pops;
    my @seqs;    # holds Bio::Seq objects to return

    # Determine number of the pop that the next hap will be taken from
    my ( $next_haps_pop_num, $haps_to_pull ) = $self->get_next_haps_pop_num;

    # If $haps_to_pull == 0, then we need to pull the whole population
    if ( $haps_to_pull == 0 ) {
        $haps_to_pull = $pops[ $next_haps_pop_num - 1 ];
    }

    for ( 1 .. $haps_to_pull ) {
        my $seq = $self->get_next_seq;
        next unless defined $seq;

        # Add Population number information to description
        $seq->display_id(" Population number $next_haps_pop_num;");
        push @seqs, $seq;
    }

    return @seqs;
}

=head3 next_run

Title   : next_run
Usage   : @seqs = $stream->next_run()
Function: reads and returns all the remaining sequences (haplotypes) in the ms
          run of the next sequence.  Returns an empty list if all haps have been
          read from the stream.  
Returns : array of Bio::Seq objects
Args    : NONE  

=cut

sub get_next_run {
    my $self = shift;

    # Let's figure out how many haps to read from the input file so that
    # we get back to the beginning of the next run.

    my ( $next_haps_pop_num, $haps_to_pull ) = $self->get_next_haps_pop_num;
    my @seqs;

    my @pops = $self->get_Pops;

    foreach ( $next_haps_pop_num .. $#pops ) {
        $haps_to_pull += $pops[$_];
    }

    # Read those haps from the input file
    # Next hap read will be the first hap of the first pop of the next run.

    for ( 1 .. $haps_to_pull ) {
        my $seq = $self->get_next_seq;
        next unless defined $seq;

        push @seqs, $seq;
    }

    return @seqs;
}

=head2 Methods to Retrieve Constants

=head3 base_conversion_table

Title   : get_base_conversion_table
Usage   : $table_hash_ref = $stream->get_base_conversion_table()
Function: returns a reference to a hash.  The keys of the hash are the letters '
          A','T','G','C'. The values associated with each key are the value that
          each letter in the sequence of a seq object returned by a
          Bio::SeqIO::msout stream should be translated to.
Returns : reference to a hash
Args    : NONE  
Synopsys:
	
	# retrieve the Bio::Seq object's sequence
	my $haplotype = $seq->seq;
	
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

    unless ( ref($fh) eq q(GLOB) ) { return; }

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

    # getting rid of excess newlines
    while ( defined($data) && $data !~ /./ ) {
        $data = <$fh>;
    }

    # In this case we are at EOF
    if ( !defined($data) ) { $self->{NEXT_RUN_NUM} = undef; return; }

    while ( $data !~ /./ ) {
        $data = <$fh>;
        chomp $data;
    }

    chomp $data;

    # If the next run is encountered, then skip to the next hap and save it in
    # the buffer.
    if ( $data eq '//' ) {
        $self->{NEXT_RUN_NUM}++;
        $self->{LAST_READ_HAP_NUM} = 0;
        for ( 1 .. 3 ) {
            $data = <$fh>;
            while ( $data !~ /./ ) {
                $data = <$fh>;
                chomp $data;
            }
            chomp $data;

            if ( $_ eq '1' ) {
                my @sites = split( /\s+/, $data );
                $self->{LAST_READ_SEGSITES} = $sites[1];
            }
            elsif ( $_ eq '2' ) {
                my @positions = split( /\s+/, $data );
                shift @positions;
                $self->{LAST_READ_POSITIONS} = \@positions;
            }
            else {
                if ( !defined($data) ) {
                    $self->throw("run $self->{NEXT_RUN_NUM} has no haps./n");
                }
                $self->{BUFFER_HAP} = $data;
            }
        }
    }
    else {
        $self->throw(
"'//' not encountered when expected. There are more haplos in one of the msOUT runs than advertised in the msinfo line."
        );
    }

}
1;
