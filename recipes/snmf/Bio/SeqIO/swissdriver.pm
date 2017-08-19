#
# BioPerl module for Bio::SeqIO::swissdriver
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Bioperl project bioperl-l(at)bioperl.org
#
# Copyright Chris Fields and contributors see AUTHORS section
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::swissdriver - SwissProt/UniProt handler-based push parser

=head1 SYNOPSIS

  #It is probably best not to use this object directly, but
  #rather go through the SeqIO handler:

  $stream = Bio::SeqIO->new(-file => $filename,
                            -format => 'swissdriver');

  while ( my $seq = $stream->next_seq() ) {
      # do something with $seq
  }

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from UniProt flat file
databases. The key difference between this parser and the tried-and-true
Bio::SeqIO::swiss parser is this version separates the parsing and data
manipulation into a 'driver' method (next_seq) and separate object handlers
which deal with the data passed to it.

=head2 The Driver

The main purpose of the driver routine, in this case next_seq(), is to carve out
the data into meaningful chunks which are passed along to relevant handlers (see
below).

Each chunk of data in the has a NAME tag attached to it, similar to that for XML
parsing. This designates the type of data passed (annotation type or seqfeature)
and the handler to be called for processing the data.

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
the bugs and their resolution. Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Bioperl Project

bioperl-l at bioperl.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# POD is at the end of the module

# Let the code begin...

# Let the code begin...

package Bio::SeqIO::swissdriver;
use vars qw(%FTQUAL_NO_QUOTE);
use strict;
use Bio::SeqIO::Handler::GenericRichSeqHandler;
use Data::Dumper;

use base qw(Bio::SeqIO);

# signals to process what's in the hash prior to next round, maps ann => names 
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
    '//'    => 'RECORDEND'
    );

# add specialized delimiters here for easier postprocessing
my %DELIM = (
    CC      => "\n",
    DR      => "\n",
    DT      => "\n",
            );

sub _initialize {
    my($self,@args) = @_;

    $self->SUPER::_initialize(@args);
    my $handler = $self->_rearrange([qw(HANDLER)],@args);
    # hash for functions for decoding keys.
    $handler ? $self->seqhandler($handler) :
    $self->seqhandler(Bio::SeqIO::Handler::GenericRichSeqHandler->new(
                    -format => 'swiss',
                    -verbose => $self->verbose,
                    -builder => $self->sequence_builder
                    ));
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
 Args    : none

=cut

sub next_seq {
    my $self = shift;
    my $hobj = $self->seqhandler;
    local($/) = "\n";
    # these contain values that need to carry over each round
    my ($featkey, $qual, $annkey, $seqdata, $location);
    my $lastann = '';
    my $ct = 0;
    # main parser
    PARSER:
    while(defined(my $line = $self->_readline)) {
        chomp $line;
        my ($ann, $data) = split(m{\s+}, $line, 2);
        if ($ann) {
            if ($ann eq 'FT') {
                # sequence features
                if ($data =~ m{^(\w+)\s+([\d\?\<]+)\s+([\d\?\>]+)(?:\s+?(\S.*))?}ox) {
                    # has location data and desc
                    if ($seqdata) {
                        $hobj->data_handler($seqdata);
                        $seqdata = ();
                    }
                    ($seqdata->{FEATURE_KEY}, my $loc1, my $loc2, $data) = ($1, $2, $3, $4);
                    $qual = 'description';
                    $seqdata->{$qual} = $data;
                    $seqdata->{NAME} = $ann;
                    $seqdata->{LOCATION} = "$loc1..$loc2" if defined $loc1;
                    next PARSER;
                } elsif ($data =~ m{^\s+/([^=]+)(?:=(.+))?}ox) {
                    # has qualifer
                    ($qual, $data) = ($1, $2 || '');
                    $ct = ($seqdata->{$qual}) ? 
                        ((ref($seqdata->{$qual}))  ? scalar(@{ $seqdata->{$qual} }) : 1)
                        : 0 ;
                }
                $data =~ s{\.$}{};
                if ($ct == 0) {
                    $seqdata->{$qual} .= ($seqdata->{$qual}) ?
                        ' '.$data : $data;                    
                } else {
                    if (!ref($seqdata->{$qual})) {
                        $seqdata->{$qual} = [$seqdata->{$qual}];
                    }
                    ($seqdata->{$qual}->[$ct]) ?
                        ($seqdata->{$qual}->[$ct] .= ' '.$data) :
                        ($seqdata->{$qual}->[$ct] .= $data);
                }
            } else {
                # simple annotations
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
                last PARSER if $ann eq '//';
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
    # some files have no // for the last file; this catches the last bit o' data
    $hobj->data_handler($seqdata) if $seqdata;
    return $hobj->build_sequence;
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object (must be seq) to the stream
 Returns : 1 for success and 0 for error
 Args    : array of 1 to n Bio::SeqI objects

=cut

sub write_seq {
    shift->throw("Use Bio::SeqIO::swiss write_seq() for output");
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

