#
# BioPerl module for Bio::SeqIO::gbdriver
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

Bio::SeqIO::gbdriver - GenBank handler-based push parser

=head1 SYNOPSIS

  #It is probably best not to use this object directly, but
  #rather go through the SeqIO handler:

  $stream = Bio::SeqIO->new(-file => $filename,
                            -format => 'gbdriver');

  while ( my $seq = $stream->next_seq() ) {
      # do something with $seq
  }

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from GenBank flat file
databases. The key difference between this parser and the tried-and-true
Bio::SeqIO::genbank parser is this version separates the parsing and data
manipulation into a 'driver' method (next_seq) and separate object handlers
which deal with the data passed to it.

=head2 The Driver

The main purpose of the driver routine, in this case next_seq(), is to carve out
the data into meaningful chunks which are passed along to relevant handlers (see
below).

Each chunk of data in the has a NAME tag attached to it, similar to that for XML
parsing. This designates the type of data passed (annotation type or seqfeature)
and the handler to be called for processing the data.

For GenBank annotations, the data is divided up and passed along to handlers
according to whether the data is tagged with a field name (i.e. LOCUS) and
whether the field name represents 'primary' annotation (in this case, is present
at the beginning of the line, such as REFERENCE). If the field is primary, it is
assigned to the NAME tag. Field names which aren't primary (have at least 2
spaces before the name, like ORGANISM) are appended to the preceding primary
field name as additional tags.

For feature table data each new feature name signals the beginning of a new
chunk of data. 'FEATURES' is attached to NAME, the feature key ('CDS', 'gene',
etc) is attached as the PRIMARY_ID, and the location is assigned to it's own tag
name (LOCATION). Feature qualifiers are added as additional keys, with multiple
keys included in an array.

Once a particular event occurs (new primary tag, sequence, end of record), the
data is passed along to be processed by a handler or (if no handler is defined)
tossed away.

Internally, the hash ref for a representative annotation (here a REFERENCE)
looks like this:

  $VAR1 = {
            'JOURNAL' => 'Unpublished (2003)',
            'TITLE' => 'The DNA sequence of Homo sapiens',
            'NAME' => 'REFERENCE',
            'REFERENCE' => '1  (bases 1 to 10001)',
            'AUTHORS' => 'International Human Genome Sequencing Consortium.'
          };

and a SeqFeature as this:

  $VAR1 = {
            'db_xref' => [
                           'GeneID:127086',
                           'InterimID:127086'
                         ],
            'LOCATION' => 'complement(3024..6641)',
            'NAME' => 'FEATURES',
            'FEATURE_KEY' => 'gene',
            'gene' => 'LOC127086',
            'note' => 'Derived by automated computational analysis using
                       gene prediction method: GNOMON.'
          };

Note that any driver implementation would suffice as long as it fulfilled the
requirements above.

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

Original author Elia Stupka, elia -at- tigem.it

=head1 CONTRIBUTORS

Ewan Birney birney at ebi.ac.uk
Jason Stajich jason at bioperl.org
Chris Mungall cjm at fruitfly.bdgp.berkeley.edu
Lincoln Stein lstein at cshl.org
Heikki Lehvaslaiho, heikki at ebi.ac.uk
Hilmar Lapp, hlapp at gmx.net
Donald G. Jackson, donald.jackson at bms.com
James Wasmuth, james.wasmuth at ed.ac.uk
Brian Osborne, bosborne at alum.mit.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# POD is at the end of the module

# Let the code begin...

package Bio::SeqIO::gbdriver;
use strict;
use warnings;
use Data::Dumper;
use Bio::SeqIO::Handler::GenericRichSeqHandler;
use Bio::Seq::SeqFactory;

use base qw(Bio::SeqIO);

# map all annotation keys to consistent INSDC-based tags for all handlers

my %FTQUAL_NO_QUOTE = map {$_ => 1} qw(
    anticodon           citation
    codon               codon_start
    cons_splice         direction
    evidence            label
    mod_base            number
    rpt_type            rpt_unit
    transl_except       transl_table
    usedin
    );


# 1) change this to indicate what should be secondary, not primary, which allows
# unknown or new stuff to be passed to handler automatically; current behavior
# appends unknowns to previous data, which isn't good since it's subtly passing
# by important data
# 2) add mapping details about how to separate data using specific delimiters


# Features are the only ones postprocessed for now
# Uncomment relevant code in next_seq and add keys as needed...
my %POSTPROCESS_DATA = map {$_ => 1} qw (FEATURES);

sub _initialize {
    my($self,@args) = @_;

    $self->SUPER::_initialize(@args);
    my $handler = $self->_rearrange([qw(HANDLER)],@args);
    # hash for functions for decoding keys.
    $handler ? $self->seqhandler($handler) :
    $self->seqhandler(Bio::SeqIO::Handler::GenericRichSeqHandler->new(
                    -format => 'genbank',
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
 Args    :

=cut

# at this point there is minimal sequence validation,
# but the parser seems to hold up nicely so far...

sub next_seq {
    my $self = shift;
    local($/) = "\n";
    my ($ann, $data, $annkey);
    my $endrec = my $seenfeat = 0;
    my $seqdata;
    my $seenlocus;
    my $hobj = $self->seqhandler;
    my $handlers = $self->seqhandler->handler_methods;
    #$self->debug(Dumper($handlers));
    PARSER:
    while (defined(my $line = $self->_readline)) {
        next if $line =~ m{^\s*$};
        
        # have to catch this at the top of the loop, then exit SEQ loop on //
        # The reason? The regex match for ann/feat keys also matches some lines
        # in the sequence; no easy way around it since some feature keys may
        # start with a number as well
        if ($ann && $ann eq 'ORIGIN') {
            SEQ:
            while (defined($line)) {
                last SEQ if index($line,'//') == 0;
                $seqdata->{DATA} .= uc $line;
                $line = $self->_readline;
            }
            $seqdata->{DATA} =~ tr{0-9 \n}{}d;
        }
        $endrec = 1 if (index($line,'//')==0);

        if ($line =~ m{^(\s{0,5})(\w+)\s+(.*)$}ox || $endrec) {
            ($ann, $data) = ($2, $3);
            unless ($seenlocus) {
                $self->throw("No LOCUS found.  Not GenBank in my book!")
                    if ($ann ne 'LOCUS');
                $seenlocus = 1;
            }
            # use the spacer to determine the annotation type
            my $len = length($1 || '');
            
            $annkey  = ($len == 0 || $len > 4)   ? 'DATA'  : $ann;
            
            # Push off the previously cached data to the handler
            # whenever a new primary annotation or seqfeature is found
            # Note use of $endrec for catching end of record
            if (($annkey eq 'DATA') && $seqdata) {
                chomp $seqdata->{DATA};
                # postprocessing for some data
                if ($seqdata->{NAME} eq 'FEATURES') {
                    $self->_process_features($seqdata)
                }
                
                # using handlers directly, slightly faster
                #my $method = (exists $handlers->{ $seqdata->{NAME} }) ?
                #        ($handlers->{$seqdata->{NAME}}) :
                #    (exists $handlers->{'_DEFAULT_'}) ?
                #        ($handlers->{'_DEFAULT_'}) :
                #    undef;
                #($method) ? ($hobj->$method($seqdata) ) :
                #        $self->debug("No handler defined for ",$seqdata->{NAME},"\n");

                # using handler methods in the Handler object, more centralized
                #$self->debug(Dumper($seqdata));
                $hobj->data_handler($seqdata);

                # bail here on //
                last PARSER if $endrec;
                # reset for next round
                $seqdata = undef;
            }

            $seqdata->{NAME} =  ($len == 0) ? $ann :   # primary ann
                                ($len > 4 ) ? 'FEATURES': # sf feature key
                                $seqdata->{NAME};      # all rest are sec. ann
            if ($seqdata->{NAME} eq 'FEATURES') {
                $seqdata->{FEATURE_KEY} = $ann;
            }
            # throw back to top if seq is found to avoid regex
            next PARSER if $ann eq 'ORIGIN';
            
        } else {
            ($data = $line) =~ s{^\s+}{};
            chomp $data;
        }
        my $delim = ($seqdata && $seqdata->{NAME} eq 'FEATURES') ? "\n" : ' ';
        $seqdata->{$annkey} .= ($seqdata->{$annkey}) ? $delim.$data : $data;
    }
    return $hobj->build_sequence;
}

sub next_chunk {
    my $self = shift;
    local($/) = "\n";
    my ($ann, $data, $annkey);
    my $endrec = my $seenfeat = 0;
    my $seqdata;
    my $seenlocus;
    my $hobj = $self->seqhandler;
    PARSER:
    while (defined(my $line = $self->_readline)) {
        next if $line =~ m{^\s*$};
        # have to catch this at the top of the loop, then exit SEQ loop on //
        # The reason? The regex match for ann/feat keys also matches some lines
        # in the sequence; no easy way around it since some feature keys may
        # start with a number as well
        if ($ann && $ann eq 'ORIGIN') {
            SEQ:
            while (defined($line)) {
                last SEQ if index($line,'//') == 0;
                $seqdata->{DATA} .= uc $line;
                $line = $self->_readline;
            }
            $seqdata->{DATA} =~ tr{0-9 \n}{}d;
        }
        $endrec = 1 if (index($line,'//')==0);

        if ($line =~ m{^(\s{0,5})(\w+)\s+(.*)$}ox || $endrec) {
            ($ann, $data) = ($2, $3);
            unless ($seenlocus) {
                $self->throw("No LOCUS found.  Not GenBank in my book!")
                    if ($ann ne 'LOCUS');
                $seenlocus = 1;
            }
            # use the spacer to determine the annotation type
            my $len = length($1 || '');
            
            $annkey  = ($len == 0 || $len > 4)   ? 'DATA'  : $ann;
            
            # Push off the previously cached data to the handler
            # whenever a new primary annotation or seqfeature is found
            # Note use of $endrec for catching end of record
            if (($annkey eq 'DATA') && $seqdata) {
                chomp $seqdata->{DATA};
                # postprocessing for some data
                if ($seqdata->{NAME} eq 'FEATURES') {
                    $self->_process_features($seqdata)
                }
                # using handler methods in the Handler object, more centralized
                $hobj->data_handler($seqdata);
                # bail here on //
                last PARSER if $endrec;
                # reset for next round
                $seqdata = undef;
            }

            $seqdata->{NAME} =  ($len == 0) ? $ann :   # primary ann
                                ($len > 4 ) ? 'FEATURES': # sf feature key
                                $seqdata->{NAME};      # all rest are sec. ann
            if ($seqdata->{NAME} eq 'FEATURES') {
                $seqdata->{FEATURE_KEY} = $ann;
            }
            # throw back to top if seq is found to avoid regex
            next PARSER if $ann eq 'ORIGIN';
        } else {
            ($data = $line) =~ s{^\s+}{};
            chomp $data;
        }
        my $delim = ($seqdata && $seqdata->{NAME} eq 'FEATURES') ? "\n" : ' ';
        $seqdata->{$annkey} .= ($seqdata->{$annkey}) ? $delim.$data : $data;
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
    shift->throw("Use Bio::SeqIO::genbank for output");
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

#=head2 _process_features
#
# Title   : _process_features
# Usage   : $self->_process_features($seqdata)
# Function: Process feature data chunk into usable bits
# Returns : 
# Args    : data chunk
#
#=cut

sub _process_features {
    my ($self, $seqdata) = @_;
    my @ftlines = split m{\n}, $seqdata->{DATA};
    delete $seqdata->{DATA};
    # don't deal with balancing quotes for now; just get rid of them...
    # Should we worry about checking whether these are balanced
    # for round-tripping tests?
    map { s{"}{}g } @ftlines;
    # all sfs start with the location...
    my $qual = 'LOCATION';
    my $ct = 0;
    for my $qualdata (@ftlines) {
        if ($qualdata =~ m{^/([^=]+)=?(.+)?}) {
            ($qual, $qualdata) = ($1, $2);
            $qualdata ||= ''; # for those qualifiers that have no data, like 'pseudo'
            $ct = (exists $seqdata->{$qual}) ? 
                  ((ref($seqdata->{$qual}))  ? scalar(@{ $seqdata->{$qual} }) : 1)
                  : 0 ;
        }
        my $delim = ($qual eq 'translation' || exists $FTQUAL_NO_QUOTE{$qual}) ?
            '' : ' ';
        # if more than one, turn into an array ref and append
        if ($ct == 0) {
            (exists $seqdata->{$qual}) ? ($seqdata->{$qual}.= $delim.$qualdata || '') :
                                         ($seqdata->{$qual} .= $qualdata || '');            
        } else {
            if (!ref($seqdata->{$qual})) {
                $seqdata->{$qual} = [$seqdata->{$qual}];
            }
            (exists $seqdata->{$qual}->[$ct]) ? (($seqdata->{$qual}->[$ct]) .= $delim.$qualdata) :
                                             (($seqdata->{$qual}->[$ct]) .= $qualdata);
        }
    }
}

1;

__END__

