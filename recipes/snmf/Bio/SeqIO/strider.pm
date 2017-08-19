# BioPerl module for Bio::SeqIO::strider
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Malcolm Cook <mec@stowers-institute.org>
#
# You may distribute this module under the same terms as perl itself
#
# _history
# April 7th, 2005  Malcolm Cook authored

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::strider - DNA strider sequence input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from strider
'binary' format, as documented in the strider manual, in which the
first 112 bytes are a header, following by the sequence, followed by a
sequence description.

Note: it does NOT assign any sequence identifier, since they are not
contained in the byte stream of the file; the Strider application
simply displays the name of the file on disk as the name of the
sequence. The caller should set the id, probably based on the name of
the file (after possibly cleaning up whitespace, which ought not to be
used as the id in most applications).

Note: the strider 'comment' is mapped to the BioPerl 'description'
(since there is no other text field, and description maps to defline
text).

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

=head1 AUTHORS - Malcolm Cook

Email: mec@stowers-institute.org

=head1 CONTRIBUTORS

Modelled after Bio::SeqIO::fasta by Ewan Birney E<lt>birney@ebi.ac.ukE<gt> and
Lincoln Stein E<lt>lstein@cshl.orgE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::strider;
use strict;
use warnings;


use Bio::Seq::SeqFactory;
use Convert::Binary::C;

use base qw(Bio::SeqIO);

my $c = Convert::Binary::C->new (
				ByteOrder => 'BigEndian',
				Alignment => 2
			       );

my $headerdef;
{local ($/);
 # See this file's __DATA__ section for the c structure definitions
 # for strider binary header data.  Here we slurp it all into $headerdef.
 $headerdef = <DATA>};

$c->parse($headerdef);

my $size_F_HEADER = 112;

die "expected strider header structure size of $size_F_HEADER" unless $size_F_HEADER eq $c->sizeof('F_HEADER');

my %alphabet2type = (
		     # map between BioPerl alphabet and strider
		     # sequence type code.

		     # From Strider Documentation: the sequence type:
		     # 1, 2, 3 and 4 for DNA, DNA Degenerate, RNA and
		     # Protein sequence files, respectively.  

		     # TODO: determine 'DNA Degenerate' based on
		     # sequence alphabet?

		     dna => 1,
		     rna => 3,
		     protein => 4,
		    );

my %type2alphabet = reverse %alphabet2type;

sub _initialize {
  my($self,@args) = @_;
  $self->SUPER::_initialize(@args);  
  unless ( defined $self->sequence_factory ) {
    $self->sequence_factory(Bio::Seq::SeqFactory->new(-verbose => $self->verbose(), 
						      -type => 'Bio::Seq::RichSeq'));
  }
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq object
 Args    : NONE

=cut

sub next_seq {
  my( $self ) = @_;
  my $fh =  $self->_fh;
  my ($header,$sequence,$fulldesc);
  eval {read $fh,$header,$size_F_HEADER};
  $self->throw ("$@  while attempting to reading strider header from " . $self->{'_file'}) if $@; 
  $self->throw("required $size_F_HEADER bytes while reading strider header in " . $self->{'_file'} . " but found: " . length($header))  
    unless $size_F_HEADER == length($header);
  my $headerdata = $c->unpack('F_HEADER',$header) or return;
  read $fh,$sequence,$headerdata->{nLength};
  read $fh,$fulldesc,$headerdata->{com_length};
  $fulldesc =~ s/\cM/ /g;	# gratuitous replacement of mac
                                # linefeed with space.
  my $seq = $self->sequence_factory->create(
					    # -id          => $main::ARGV, #might want to set this in caller to $ARGV.
					    -seq         => $sequence,
					    -desc        => $fulldesc,
					    -alphabet    => $type2alphabet{$headerdata->{type}} || 'dna',
					   );

  return $seq;
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq(@seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : array of 1 to n Bio::PrimarySeqI objects


=cut

sub write_seq {
  my ($self,@seq) = @_;
  my $fh =  $self->_fh() || *STDOUT; #die "could not determine filehandle in strider.pm";
  foreach my $seq (@seq) {
    $self->throw("Did not provide a valid Bio::PrimarySeqI object") 
      unless defined $seq && ref($seq) && $seq->isa('Bio::PrimarySeqI');
    my  $headerdata = $c->pack('F_HEADER',{
					   versionNb   => 0, 
					   type        => $alphabet2type{$seq->alphabet} || $alphabet2type{dna},
					   topology    => $seq->is_circular ? 1 : 0,
					   nLength     => $seq->length,
					   nMinus      => 0,
					   com_length  => length($seq->desc || ""),
					  });
    print $fh $headerdata, $seq->seq() || "" , $seq->desc || "";
  }
}

1;

__DATA__

//The following was taken from the strider 1.4 release notes Appendix (with
//some comments gleaned from other parts of manual)

struct F_HEADER
{
char versionNb;  // the format version number, currently it is set to 0
char type;       // 1=DNA, 2=DNA Degenerate, 3=RNA or 4=Protein
char topology;   // linear or circular - 0 for a linear sequence, 1 for a circular one
char reserved1;
int reserved2;
int reserved3;
int reserved4;
char reserved5;
char filler1;
short filler2;
int filler3;
int reserved6;
int nLength; // Sequence length -  the length the Sequence field (the number of char in the text, each being a base or an aa)
int nMinus; // nb of "negative" bases, i.e. the number of bases numbered with negative numbers
int reserved7;
int reserved8;
int reserved9;
int reserved10;
int reserved11;
char reserved12[32];
short reserved13;
short filler4;
char reserved14;
char reserved15;
char reserved16;
char filler5;
int com_length; //  the length the Comment field (the number of char in the text).
int reserved17;
int filler6;
int filler7;
};
