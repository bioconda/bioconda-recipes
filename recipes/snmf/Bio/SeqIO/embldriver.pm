#
# BioPerl module for Bio::SeqIO::embldriver
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::embldriver - EMBL sequence input/output stream

=head1 SYNOPSIS

It is probably best not to use this object directly, but
rather go through the SeqIO handler system. Go:

    $stream = Bio::SeqIO->new(-file => $filename, -format => 'embldriver');

    while ( (my $seq = $stream->next_seq()) ) {
        # do something with $seq
    }

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from EMBL flat
file databases.

There is a lot of flexibility here about how to dump things which
should be documented more fully.

There should be a common object that this and Genbank share (probably
with Swissprot). Too much of the magic is identical.

=head2 Optional functions

=over 3

=item _show_dna()

(output only) shows the dna or not

=item _post_sort()

(output only) provides a sorting func which is applied to the FTHelpers
before printing

=item _id_generation_func()

This is function which is called as

   print "ID   ", $func($annseq), "\n";

To generate the ID line. If it is not there, it generates a sensible ID
line using a number of tools.

If you want to output annotations in EMBL format they need to be
stored in a Bio::Annotation::Collection object which is accessible
through the Bio::SeqI interface method L<annotation()|annotation>.

The following are the names of the keys which are polled from a
L<Bio::Annotation::Collection> object.

 reference  - Should contain Bio::Annotation::Reference objects
 comment    - Should contain Bio::Annotation::Comment objects
 dblink     - Should contain Bio::Annotation::DBLink objects

=back

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
the bugs and their resolution. Bug reports can be submitted via
the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::embldriver;
use vars qw(%FTQUAL_NO_QUOTE);
use strict;
use Bio::SeqIO::Handler::GenericRichSeqHandler;
use Data::Dumper;

use base qw(Bio::SeqIO);

my %FTQUAL_NO_QUOTE = map {$_ => 1} qw(
    anticodon           citation
    codon               codon_start
    cons_splice         direction
    evidence            label
    mod_base            number
    rpt_type            rpt_unit
    transl_except       transl_table
    usedin
    LOCATION
    );

my %DATA_KEY = (
    ID      => 'ID',
    AC      => 'ACCESSION',
    DT      => 'DATE',
    DE      => 'DESCRIPTION',
    KW      => 'KEYWORDS',
    OS      => 'SOURCE',
    OC      => 'CLASSIFICATION',
    OG      => 'ORGANELLE',
    RN      => 'REFERENCE',
    RA      => 'AUTHORS',
    RC      => 'COMMENT',
    RG      => 'CONSRTM',
    RP      => 'POSITION',
    RX      => 'CROSSREF',
    RT      => 'TITLE',
    RL      => 'LOCATION',
    XX      => 'SPACER',
    FH      => 'FEATHEADER',
    FT      => 'FEATURES',
    AH      => 'TPA_HEADER',  # Third party annotation
    AS      => 'TPA_DATA',  # Third party annotation
    DR      => 'DBLINK',
    CC      => 'COMMENT',
    CO      => 'CO',
    CON     => 'CON',
    WGS     => 'WGS',
    ANN     => 'ANN',
    TPA     => 'TPA',
    SQ      => 'SEQUENCE',
    );

my %SEC = (
    OC      => 'CLASSIFICATION',
    OH      => 'HOST', # not currently handled, bundled with organism data for now
    OG      => 'ORGANELLE',
    OX      => 'CROSSREF',
    RA      => 'AUTHORS',
    RC      => 'COMMENT',
    RG      => 'CONSRTM',
    RP      => 'POSITION',
    RX      => 'CROSSREF',
    RT      => 'TITLE',
    RL      => 'JOURNAL',
    AS      => 'ASSEMBLYINFO',  # Third party annotation    
    );

my %DELIM = (
    #CC      => "\n",
    #DR      => "\n",
    #DT      => "\n",
            );

# signals to process what's in the hash prior to next round
# these should be changed to map secondary data
my %PRIMARY = map {$_ => 1} qw(ID AC DT DE SV KW OS RN AH DR FH CC SQ FT WGS CON ANN TPA //);

sub _initialize {
    my($self,@args) = @_;

    $self->SUPER::_initialize(@args);
    my $handler = $self->_rearrange([qw(HANDLER)],@args);
    # hash for functions for decoding keys.
    $handler ? $self->seqhandler($handler) :
    $self->seqhandler(Bio::SeqIO::Handler::GenericRichSeqHandler->new(
                    -format => 'embl',
                    -verbose => $self->verbose,
                    -builder => $self->sequence_builder
                    ));
    #
    if( ! defined $self->sequence_factory ) {
        $self->sequence_factory(Bio::Seq::SeqFactory->new
                (-verbose => $self->verbose(),
                 -type => 'Bio::Seq::RichSeq'));
    }
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq object
 Args    :

=cut

sub next_seq {
    my $self = shift;
    my $hobj = $self->seqhandler;
    local($/) = "\n";
    my ($featkey, $qual, $annkey, $delim, $seqdata);
    my $lastann = '';
    my $ct = 0;
    PARSER:
    while(defined(my $line = $self->_readline)) {
        next PARSER if $line =~ m{^\s*$};
        chomp $line;
        my ($ann,$data) = split m{\s{2,3}}, $line , 2;
        next PARSER if ($ann eq 'XX' || $ann eq 'FH');
        if ($ann) {
            $data ||='';
            if ($ann eq 'FT') {
                # seqfeatures
                if ($data =~ m{^(\S+)\s+([^\n]+)}) {
                    $hobj->data_handler($seqdata) if $seqdata;
                    $seqdata = ();
                    ($seqdata->{FEATURE_KEY}, $data) = ($1, $2);
                    $seqdata->{NAME} = $ann;
                    $qual = 'LOCATION';
                } elsif ($data =~ m{^\s+/([^=]+)=?(.+)?}) {
                    ($qual, $data) = ($1, $2 ||'');
                    $ct = (exists $seqdata->{$qual}) ? 
                        ((ref($seqdata->{$qual}))  ? scalar(@{ $seqdata->{$qual} }) : 1)
                        : 0 ;
                }
                $data =~ s{^\s+}{};
                $data =~ tr{"}{}d; # we don't care about quotes yet...
                my $delim = ($FTQUAL_NO_QUOTE{$qual}) ? '' : ' ';
                if ($ct == 0) {
                    $seqdata->{$qual} .= ($seqdata->{$qual}) ?
                        $delim.$data :
                        $data;
                } else {
                    if (!ref($seqdata->{$qual})) {
                        $seqdata->{$qual} = [$seqdata->{$qual}];
                    }
                    (exists $seqdata->{$qual}->[$ct]) ?
                        (($seqdata->{$qual}->[$ct]) .= $delim.$data) :
                        (($seqdata->{$qual}->[$ct]) .= $data);
                }
            } else {
                # simple annotations
                $data =~ s{;$}{};
                last PARSER if $ann eq '//';
                if ($ann ne $lastann) {
                    if (!$SEC{$ann} && $seqdata) {
                        $hobj->data_handler($seqdata);
                        # can't use undef here; it can lead to subtle mem leaks
                        $seqdata = ();
                    }
                    $annkey = (!$SEC{$ann})    ? 'DATA'     : # primary data
                              $SEC{$ann};
                    $seqdata->{'NAME'} = $ann if !$SEC{$ann};
                }
                
                # toss the data for SQ lines; this needs to be done after the
                # call to the data handler
                
                next PARSER if $ann eq 'SQ';
                my $delim = $DELIM{$ann} || ' ';
                $seqdata->{$annkey} .= ($seqdata->{$annkey}) ?
                    $delim.$data : $data;
                $lastann = $ann;
            } 
        } else {
            # this should only be sequence (fingers crossed!)
            SEQUENCE:
            while (defined ($line = $self->_readline)) {
                if (index($line, '//') == 0) {
                    $data =~ tr{0-9 \n}{}d;
                    $seqdata->{DATA} = $data;
                    #$self->debug(Dumper($seqdata));
                    $hobj->data_handler($seqdata);
                    $seqdata = ();
                    last PARSER;
                } else {                        
                    $data .= $line;
                    $line = undef;
                }
            }
        }
    }
    $hobj->data_handler($seqdata) if $seqdata;
    $seqdata = ();
    return $hobj->build_sequence;
}

sub next_chunk {
    my $self = shift;
    my $ct = 0;
    PARSER:
    while(defined(my $line = $self->_readline)) {
        next if $line =~ m{^\s*$};
        chomp $line;
        my ($ann,$data) = split m{\s{2,3}}, $line , 2;
        $data ||= '';
        $self->debug("Ann: [$ann]\n\tData: [$data]\n");
        last PARSER if $ann =~ m{//};
    }
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object (must be seq) to the stream
 Returns : 1 for success and 0 for error
 Args    : array of 1 to n Bio::SeqI objects

=cut

sub write_seq {
    shift->throw("Use Bio::SeqIO::embl for output");
    # maybe make a Writer class as well????
}

=head2 seqhandler

 Title   : seqhandler
 Usage   : $stream->seqhandler($handler)
 Function: Get/Set teh Bio::Seq::HandlerBaseI object
 Returns : Bio::Seq::HandlerBaseI 
 Args    : Bio::Seq::HandlerBaseI 

=cut

sub seqhandler {
    my ($self, $handler) = @_;
    if ($handler) {
        $self->throw("Not a Bio::HandlerBaseI") unless
        ref($handler) && $handler->isa("Bio::HandlerBaseI");
        $self->{'_seqhandler'} = $handler;
    }
    return $self->{'_seqhandler'};
}

1;

__END__

