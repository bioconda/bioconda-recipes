#
# BioPerl module for Bio::SeqIO::game
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Sheldon McKay <mckays@cshl.edu>
#
# You may distribute this module under the same terms as perl itself
#

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::game -- a class for parsing and writing game-XML

=head1 SYNOPSIS

This module is not used directly, use SeqIO.

 use Bio::SeqIO;

 my $in = Bio::SeqIO->new ( -file    => 'file.xml', 
                            -format  =>  'game',
                            -verbose => 1 );

 my $seq = $in->next_seq;

=head1 DESCRIPTION

Bio::SeqIO::game will parse game XML (version 1.2) or write game XML from 
a Bio::SeqI implementing object.  The XML is readable by the genome 
annotation editor 'Apollo' (www.gmod.org).  It is not backwards compatible 
with the previous version of game XML.  The XML format currently used by 
Apollo contains a single 'main' annotated sequence, so we will only get a 
single annotated sequence in the stream when parsing a game-XML record.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
to one of the Bioperl mailing lists.

Your participation is much appreciated.

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
of the bugs and their resolution.

Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Sheldon McKay

Email mckays@cshl.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

package Bio::SeqIO::game;

use Bio::SeqIO::game::gameHandler;
use Bio::SeqIO::game::gameWriter;

use base qw(Bio::SeqIO);

sub _initialize {
    my ($self, @args) = @_;
    $self->SUPER::_initialize(@args);
}

=head2 next_seq

 Title   : next_seq
 Usage   : my $seq = $seqio->next_seq;
 Function: get the main sequence object
 Returns : a Bio::Seq::RichSeq object
 Args    : none


=cut

sub next_seq {
    my $self   = shift;
    
    my $seq_l  = $self->_getseqs;
    my $annseq = shift @{$seq_l};
    my $seq    = $annseq->[0];
    my $feats  = $annseq->[1];
    
    for ( @{$feats} ) {
	$seq->add_SeqFeature( $_ );
    }

    return $seq;
}   

=head2 write_seq

 Title   : write_seq
 Usage   : $seqio->write_seq($seq)
 Function: writes a sequence object as game XML
 Returns : nothing
 Args    : a Bio::SeqI compliant object

=cut

sub write_seq {
    my ($self, $seq) = @_;
    my $writer = Bio::SeqIO::game::gameWriter->new($seq);
    my $xml = $writer->write_to_game;
    $self->_print($xml);
}

=head2 _getseqs

 Title   : _getseqs
 Usage   : $self->_getseqs
 Function: An internal method to invoke the PerlSAX XML handler and get
           the sequence objects
 Returns : an reference to an array with sequence object and annotations
 Args    : none

=cut

sub _getseqs {
    my $self = shift;
    if ( defined $self->{seq_l} ) {
        return $self->{seq_l};
    }
    else {
	my $fh = $self->_fh;
	my $text = join '', <$fh>;
	$text || $self->throw("Input file is empty or does not exist");
	my $source = $text =~ /type>(source|origin|\bregion\b)<\/type/gm ? 1 : 0;
        my $handler = Bio::SeqIO::game::gameHandler->new;
	$handler->{has_source} = $source if $source;
	$handler->{verbose} = 1 if $self->verbose;
        my $parser  = XML::Parser::PerlSAX->new( Handler => $handler );
        my $game    = $parser->parse( $text );
	$self->{seq_l} = $game->load;
    }
}

=head2 _hide_dna

 Title   : _hide_dna
 Usage   : $seqio->_hide_dna
 Function: Hide the DNA for really huge sequences
 Returns : nothing 
 Args    : none

=cut

sub _hide_dna {
    my $self = shift;
    
    my $annseqs = $self->_getseqs;

    for ( @{$annseqs} ) {
        my $seq = $_->[0];
        $seq->seq('');
    }
    return 0;
}


1;
