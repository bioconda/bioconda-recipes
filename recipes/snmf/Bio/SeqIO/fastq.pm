# POD at __END__, let the code begin...

package Bio::SeqIO::fastq;
use strict;

use Bio::Seq::SeqFactory;

use base qw(Bio::SeqIO);

our %variant = (
        sanger     => {
            'offset'     => 33,
            'qual_start' => 0,
            'qual_end'   => 93
            },
        solexa     => {
            'offset'     => 64,
            'qual_start' => -5,
            'qual_end'   => 62
            },
        illumina   => {
            'offset'     => 64,
            'qual_start' => 0,
            'qual_end'   => 62
            },
    );

sub _initialize {
    my($self,@args) = @_;
    $self->SUPER::_initialize(@args);
    my ($variant, $validate, $header) = $self->_rearrange([qw(VARIANT
                                                              VALIDATE
                                                              QUALITY_HEADER)], @args);
    $variant ||= 'sanger';
    $self->variant($variant);
    $self->_init_tables($variant);
    $validate = defined $validate ? $validate : 1;
    $self->validate($validate);
    $header     && $self->quality_header($header);

    if( ! defined $self->sequence_factory ) {
        $self->sequence_factory(Bio::Seq::SeqFactory->new(
            -verbose => $self->verbose(),
            -type => 'Bio::Seq::Quality')
        );
    }
}

sub next_seq {
    my( $self ) = @_;
    while (defined(my $data = $self->next_dataset)) {
        # Are FASTQ sequences w/o any sequence valid?  Removing for now
        # -cjfields 6.22.09
        my $seq = $self->sequence_factory->create(%$data);
        return $seq;
    }
    return;
}

# pure perl version
sub next_dataset {
    my $self = shift;
    local $/ = "\n";
    my $data;
    my $mode = '-seq';
    # speed this up by directly accessing the filehandle and in-lining the
    # _readline stuff vs. making the repeated method calls. Tradeoff is speed
    # over repeated code.

    # we can probably normalize line endings using PerlIO::eol or
    # Encode::Newlines

    my $fh = $self->_fh;
    my $line = $self->{lastline} || <$fh>;

    FASTQ:
    while (defined $line) {
        $line =~ s/\015\012/\012/;
        $line =~ tr/\015/\n/;
        if ($mode eq '-seq' && $line =~ m{^@([^\n]+)$}xmso) {
            $data->{-descriptor} = $1;
            my ($id,$fulldesc);
            if ($data->{-descriptor} =~ /^\s*(\S+)\s*(.*)/) {
                ($id,$fulldesc) = ($1, $2);
            } else {
                $self->throw("Can't parse fastq header");
            }
            $data->{-id} = $id;
            $data->{-desc} = $fulldesc;
            $data->{-namespace} = $self->variant;
        } elsif ($mode eq '-seq' && $line =~ m{^\+([^\n]*)}xmso) {
            my $desc = $1;
            $self->throw("No description line parsed") unless $data->{-descriptor};
            if ($desc && $data->{-descriptor} ne $desc) {
                $self->throw("Quality descriptor [$desc] doesn't match seq ".
                    "descriptor ".$data->{-descriptor}.", line: $." );
            }
            $mode = '-raw_quality';
        } else {
            if ($mode eq '-raw_quality' && defined($data->{-raw_quality}) &&
                (length($data->{-raw_quality}) >= length($data->{-seq}))) {
                $self->{lastline} = $line;
                last FASTQ
            }
            chomp $line;
            if ($line =~ /^$/) {
                delete $self->{lastline};
                last FASTQ;
            }
            $data->{$mode} .= $line
        }
        $line = <$fh>;
        if (!defined $line) {
            delete $self->{lastline};
            last FASTQ;
        }
    }

    return unless $data;
    if (!$data->{-seq} || !defined($data->{-raw_quality})) {
        $self->throw("Missing sequence and/or quality data; line: $.");
    }

    # simple quality control tests
    if (length $data->{-seq} != length $data->{-raw_quality}) {
        $self->throw("Quality string [".$data->{-raw_quality}."] of length [".
            length($data->{-raw_quality})."]\ndoesn't match length of sequence ".
            $data->{-seq}."\n[".length($data->{-seq})."], line: $.");
    }

    $data->{-qual} = [map {
        if ($self->{_validate_qual} && !exists($self->{chr2qual}->{$_})) {
            $self->throw("Unknown symbol with ASCII value ".ord($_)." outside ".
                "of quality range")
            # TODO: fallback?
        }
        $self->variant eq 'solexa' ?
            $self->{sol2phred}->{$self->{chr2qual}->{$_}}:
            $self->{chr2qual}->{$_};
    } unpack("A1" x length($data->{-raw_quality}), $data->{-raw_quality})];
    return $data;
}

# This should be creating fastq output only.  Bio::SeqIO::fasta and
# Bio::SeqIO::qual should be used for that output

sub write_seq {
    my ($self,@seq) = @_;
    my $var = $self->variant;
    foreach my $seq (@seq) {
        unless ($seq->isa("Bio::Seq::Quality")){
            $self->warn("You can't write FASTQ without supplying a Bio::Seq::".
                "Quality object! ".ref($seq)."\n");
            next;
        }
        my $str = $seq->seq || '';
        my @qual = @{$seq->qual};

        # this should be the origin of the sequence (illumina, solexa, sanger)
        my $ns= $seq->namespace;

        my $top = $seq->display_id();
        if (my $desc = $seq->desc()) {
            $desc =~ s/\n//g;
            $top .= " $desc";
        }
        my $qual = '';
        my $qual_map =
            ($ns eq 'solexa' && $var eq 'solexa') ? $self->{phred_fp2chr} :
            ($var eq 'solexa')                    ? $self->{phred_int2chr} :
            $self->{qual2chr};

        my %bad_qual;
        for my $q (@qual) {
            $q = sprintf("%.0f", $q) if ($var ne 'solexa' && $ns eq 'solexa');
            if (exists $qual_map->{$q}) {
                $qual .= $qual_map->{$q};
                next;
            } else {
                # fuzzy mapping, for edited qual scores
                my $qr = sprintf("%.0f",$q);
                my $bounds = sprintf("%.1f-%.1f",$qr-0.5, $qr+0.5);
                if (exists $self->{fuzzy_qual2chr}->{$bounds}) {
                    $qual .= $self->{fuzzy_qual2chr}->{$bounds};
                    next;
                } else {
                    my $rep = ($q <= $self->{qual_start}) ?
                        $qual_map->{$self->{qual_start}} : $qual_map->{$self->{qual_end}};
                    $qual .= $rep;
                    $bad_qual{$q}++;
                }
            }
        }
        if ($self->{_validate_qual} && %bad_qual) {
            $self->warn("Data loss for $var: following values not found\n".
                        join(',',sort {$a <=> $b} keys %bad_qual))
        }
        $self->_print("\@",$top,"\n",$str,"\n") or return;
        $self->_print("+",($self->{_quality_header} ? $top : ''),"\n",$qual,"\n") or return;
    }
    return 1;
}

sub write_fastq {
    my ($self,@seq) = @_;
    return $self->write_seq(@seq);
}

sub write_fasta {
    my ($self,@seq) = @_;
    if (!exists($self->{fasta_proxy})) {
        $self->{fasta_proxy} = Bio::SeqIO->new(-format => 'fasta', -fh => $self->_fh);
    }
    return $self->{fasta_proxy}->write_seq(@seq);
}

sub write_qual {
    my ($self,@seq) = @_;
    if (!exists($self->{qual_proxy})) {
        $self->{qual_proxy} = Bio::SeqIO->new(-format => 'qual', -fh => $self->_fh);
    }
    return $self->{qual_proxy}->write_seq(@seq);
}

# variant() method inherited from Bio::Root::IO

sub _init_tables {
    my ($self, $var) = @_;
    # cache encode/decode values for quicker accession
    ($self->{qual_start}, $self->{qual_end}, $self->{qual_offset}) =
        @{ $variant{$var} }{qw(qual_start qual_end offset)};
    if ($var eq 'solexa') {
        for my $q ($self->{qual_start} .. $self->{qual_end}) {
            my $char = chr($q + $self->{qual_offset});
            $self->{chr2qual}->{$char} = $q;
            $self->{qual2chr}->{$q} = $char;
            my $s2p = 10 * log(1 + 10 ** ($q / 10.0)) / log(10);

            # solexa <=> solexa mapping speedup (retain floating pt precision)
            $self->{phred_fp2chr}->{$s2p} = $char;
            $self->{sol2phred}->{$q} = $s2p;

            # this is for mapping values fuzzily (fallback)
            $self->{fuzzy_qual2chr}->{sprintf("%.1f-%.1f",$q - 0.5, $q + 0.5)} = $char;

            next if $q < 0; # skip loop; PHRED scores greater than 0
            my $p2s = sprintf("%.0f",($q <= 1) ? -5 : 10 * log(-1 + 10 ** ($q / 10.0)) / log(10));
            # sanger/illumina PHRED <=> Solexa char mapping speedup
            $self->{phred_int2chr}->{$q} = chr($p2s + $self->{qual_offset});
        }
    } else {
        for my $c ($self->{qual_start}..$self->{qual_end}) {
            # PHRED mapping
            my $char = chr($c + $self->{qual_offset});
            $self->{chr2qual}->{$char} = $c;
            $self->{qual2chr}->{$c} = $char;
            # this is for mapping values not found with above
            $self->{fuzzy_qual2chr}->{sprintf("%.1f-%.1f",$c - 0.5, $c + 0.5)} = $char;
        }
    }
}

sub validate {
    my ($self, $val) = @_;
    if (defined $val) {
        $self->{_validate_qual} = $val;
    }
    return $self->{_validate_qual};
}

sub quality_header{
    my ($self, $val) = @_;
    if (defined $val) {
        $self->{_quality_header} = $val;
    }
    return $self->{_quality_header} || 0;
}

1;

__END__

# BioPerl module for Bio::SeqIO::fastq
#
# Please direct questions and support issues to <bioperl-l@bioperl.org>
#
# Cared for Chris Fields
#
# Completely refactored from the original FASTQ parser
# by Tony Cox <avc@sanger.ac.uk>
#
# Copyright Chris Fields
#
# You may distribute this module under the same terms as perl itself
#
# _history
#
# October 29, 2001  incept data (Tony Cox)
# June 20, 2009 updates for Illumina variant FASTQ formats for Solexa and later
# Aug 26, 2009  fixed bugs and added tests for fastq.t

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::fastq - fastq sequence input/output stream

=head1 SYNOPSIS

  ################## pertains to FASTQ parsing only ##################

  # grabs the FASTQ parser, specifies the Illumina variant
  my $in = Bio::SeqIO->new(-format    => 'fastq-illumina',
                           -file      => 'mydata.fq');

  # simple 'fastq' format defaults to 'sanger' variant
  my $out = Bio::SeqIO->new(-format    => 'fastq',
                            -file      => '>mydata.fq');

  # $seq is a Bio::Seq::Quality object
  while (my $seq = $in->next_seq) {
      $out->write_seq($seq);  # convert Illumina 1.3 to Sanger format
  }

  # for 4x faster parsing, one can do something like this for raw data
  use Bio::Seq::Quality;

  # $data is a hash reference containing all arguments to be passed to
  # the Bio::Seq::Quality constructor
  while (my $data = $in->next_dataset) {
      # process $data, such as trim, etc
      my $seq = Bio::Seq::Quality->new(%$data);

      # for now, write_seq only accepts Bio::Seq::Quality, but may be modified
      # to allow raw hash references for speed
      $out->write_seq($data);
  }

=head1 DESCRIPTION

This object can transform Bio::Seq and Bio::Seq::Quality objects to and from
FASTQ flat file databases.

FASTQ is a file format used frequently at the Sanger Centre and in next-gen
sequencing to bundle a FASTA sequence and its quality data. A typical FASTQ
entry takes the form:

  @HCDPQ1D0501
  GATTTGGGGTTCAAAGCAGTATCGATCAAATAGTAAATCCATTTGTTCAACTCACAGTTT.....
  +HCDPQ1D0501
  !''*((((***+))%%%++)(%%%%).1***-+*''))**55CCF>>>>>>CCCCCCC65.....

where:

  @ = descriptor, followed by one or more sequence lines
  + = optional descriptor (if present, must match first one), followed by one or
      more qual lines

When writing FASTQ output the redundant descriptor following the '+' is by
default left off to save disk space. If needed, one can set the quality_header()
flag in order for this to be printed.

=head2 FASTQ and Bio::Seq::Quality mapping

FASTQ files have sequence and quality data on single line or multiple lines, and
the quality values are single-byte encoded. Data are mapped very simply to
Bio::Seq::Quality instances:

    Data                                        Bio::Seq::Quality method
    ------------------------------------------------------------------------
    first non-whitespace chars in descriptor    id^
    descriptor line                             desc^
    sequence lines                              seq
    quality                                     qual*
    FASTQ variant                               namespace

    ^ first nonwhitespace chars are id(), everything else after (to end of line)
      is in desc()
    * Converted to PHRED quality scores where applicable ('solexa')

=head2 FASTQ variants

This parser supports all variants of FASTQ, including Illumina v 1.0 and 1.3:

    variant                note
    -----------------------------------------------------------
    sanger                 original
    solexa                 Solexa, Inc. (2004), aka Illumina 1.0
    illumina               Illumina 1.3

The variant can be specified by passing by either passing the additional
-variant parameter to the constructor:

  my $in = Bio::SeqIO->new(-format    => 'fastq',
                           -variant   => 'solexa',
                           -file      => 'mysol.fq');

or by passing the format and variant together (Bio::SeqIO will now handle
this and convert it accordingly to the proper argument):

  my $in = Bio::SeqIO->new(-format    => 'fastq-solexa',
                           -file      => 'mysol.fq');

Variants can be converted back and forth from one another; however, due to
the difference in scaling for solexa quality reads, converting from 'illumina'
or 'sanger' FASTQ to solexa is not recommended.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support

Please direct usage questions or support issues to the mailing list:

I<bioperl-l@bioperl.org>

rather than to the module maintainer directly. Many experienced and
reponsive experts will be able look at the problem and quickly
address it. Please include a thorough description of the problem
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via the
web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHORS - Chris Fields (taken over from Tony Cox)

Email: cjfields at bioperl dot org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=head1 Bio::SeqIO interface methods

=head2 next_seq

 Title    : next_seq
 Usage    : $seq = $stream->next_seq()
 Function : returns the next sequence in the stream
 Returns  : Bio::Seq::Quality object
 Args     : NONE
 Status   : Stable

=head2 write_seq

 Title    : write_seq
 Usage    : $stream->write_seq(@seq)
 Function : writes the $seq object into the stream
 Returns  : 1 for success and 0 for error
 Args     : Bio::Seq::Quality
 Note     : This now conforms to SeqIO spec (module output is same format as
            next_seq)
 Status   : Stable

=head2 variant

 Title   : variant
 Usage   : $format  = $obj->variant();
 Function: Get and set method for the quality sequence variant.  This is
           important for indicating the encoding/decoding to be used for
           quality data.

           Current values accepted are:
            'sanger'   (orginal FASTQ)
                ASCII encoding from 33-126, PHRED quality score from 0 to 93
            'solexa'   (aka illumina1.0)
                ASCII encoding from 59-104, SOLEXA quality score from -5 to 40
            'illumina' (aka illumina1.3)
                ASCII encoding from 64-104, PHRED quality score from 0 to 40

            (Derived from the MAQ website):
            For 'solexa', scores are converted to PHRED qual scores using:
                $Q = 10 * log(1 + 10 ** (ord($sq) - 64) / 10.0)) / log(10)


 Returns : string
 Args    : new value, string

=head1 Plugin-specific methods

=head2 next_dataset

 Title    : next_dataset
 Usage    : $obj->next_dataset
 Function : returns a hash reference containing the parsed data
 Returns  : hash reference
 Args     : none
 Status   : Stable

=head2 write_fastq

 Title   : write_fastq
 Usage   : $stream->write_fastq(@seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq::Quality object
 Status  : Deprecated (delegates to write_seq)

=head2 write_fasta

 Title   : write_fasta
 Usage   : $stream->write_fasta(@seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq object
 Note    : This method does not currently delegate to Bio::SeqIO::fasta
           (maybe it should?).  Not sure whether we should keep this as a
           convenience method.
 Status  : Unstable

=head2 write_qual

 Title   : write_qual
 Usage   : $stream->write_qual(@seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq::Quality object
 Note    : This method does not currently delegate to Bio::SeqIO::qual
           (maybe it should?).  Not sure whether we should keep this as a
           convenience method.
 Status  : Unstable

=head2 validate

 Title    : validate
 Usage    : $obj->validate(0)
 Function : flag for format/qual range validation - default is 1, validate
 Returns  : Bool (0/1)
 Args     : Bool (0/1)
 Status   : Stable (may be moved to interface)

=head2 quality_header

 Title    : quality_header
 Usage    : $obj->quality_header
 Function : flag for printing quality header - default is 0, no header
 Returns  : Bool (0/1)
 Args     : Bool (0/1)
 Status   : Unstable (name may change dep. on feedback)

=cut
