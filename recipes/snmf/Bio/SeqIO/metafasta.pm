# BioPerl module for Bio::SeqIO::metafasta
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Heikki Lehvaslaiho
#
# Copyright Heikki Lehvaslaiho
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::metafasta - metafasta sequence input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

  use Bio::SeqIO;

  # read the metafasta file
  $io = Bio::SeqIO->new(-file => "test.metafasta",
                        -format => "metafasta" );

  $seq = $io->next_seq;

=head1 DESCRIPTION

This object can transform Bio::Seq::Meta objects to and from metafasta
flat file databases.

For sequence part the code is an exact copy of Bio::SeqIO::fasta
module. The only added bits deal with meta data IO.

The format of a metafasta file is

  >test
  ABCDEFHIJKLMNOPQRSTUVWXYZ
  &charge
  NBNAANCNJCNNNONNCNNUNNXNZ
  &chemical
  LBSAARCLJCLSMOIMCHHULRXRZ

where the sequence block is followed by one or several meta blocks.
Each meta block starts with the ampersand character '&' in the first
column and is immediately followed by the name of the meta data which
continues until the new line. The meta data follows it. All
characters, except new line, are important in meta data.

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

=head1 AUTHOR - Heikki Lehvaslaiho

Email heikki-at-bioperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::metafasta;
use vars qw($WIDTH);
use strict;

use Bio::Seq::SeqFactory;
use Bio::Seq::SeqFastaSpeedFactory;
use Bio::Seq::Meta;

use base qw(Bio::SeqIO);

BEGIN { $WIDTH = 60}

sub _initialize {
  my($self,@args) = @_;
  $self->SUPER::_initialize(@args);
  my ($width) = $self->_rearrange([qw(WIDTH)], @args);
  $width && $self->width($width);
  unless ( defined $self->sequence_factory ) {
      $self->sequence_factory(Bio::Seq::SeqFastaSpeedFactory->new());
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
	my $seq;
	my $alphabet;
	local $/ = "\n>";
	return unless my $entry = $self->_readline;

	chomp($entry);
	if ($entry =~ m/\A\s*\Z/s)  { # very first one
		return unless $entry = $self->_readline;
		chomp($entry);
	}
	$entry =~ s/^>//;

	my ($top,$sequence) = split(/\n/,$entry,2);
	defined $sequence && $sequence =~ s/>//g;

	my @metas;
	($sequence, @metas) = split /\n&/, $sequence;

	my ($id,$fulldesc);
	if( $top =~ /^\s*(\S+)\s*(.*)/ ) {
		($id,$fulldesc) = ($1,$2);
	}

	if (defined $id && $id eq '') {$id=$fulldesc;} # FIX incase no space 
	                                               # between > and name \AE
	defined $sequence && $sequence =~ s/\s//g;	  # Remove whitespace

	# for empty sequences we need to know the mol.type
	$alphabet = $self->alphabet();
	if(defined $sequence && length($sequence) == 0) {
		if(! defined($alphabet)) {
			# let's default to dna
			$alphabet = "dna";
		}
	} else {
		# we don't need it really, so disable
		$alphabet = undef;
	}

	$seq = $self->sequence_factory->create(
						-seq         => $sequence,
						-id          => $id,
					   # Ewan's note - I don't think this healthy
					   # but obviously to taste.
					   #-primary_id  => $id,
					   -desc        => $fulldesc,
					   -alphabet    => $alphabet,
					   -direct      => 1,
													  );

	$seq = $seq->primary_seq;
	bless $seq, 'Bio::Seq::Meta';

	foreach my $meta (@metas) {
		my ($name,$string) = split /\n/, $meta;
		# $split ||= '';
		$string =~ s/\n//g;	# Remove newlines, spaces are important
		$seq->named_meta($name, $string);
	}

	# if there wasn't one before, set the guessed type
	unless ( defined $alphabet ) {
		$self->alphabet($seq->alphabet());
	}
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
   my $width = $self->width;
   foreach my $seq (@seq) {
       $self->throw("Did not provide a valid Bio::PrimarySeqI object") 
	   unless defined $seq && ref($seq) && $seq->isa('Bio::PrimarySeqI');

       my $str = $seq->seq;
       my $top = $seq->display_id();
       if ($seq->can('desc') and my $desc = $seq->desc()) {
	   $desc =~ s/\n//g;
	   $top .= " $desc";
       }
       if(length($str) > 0) {
	   $str =~ s/(.{1,$width})/$1\n/g;
       } else {
	   $str = "\n";
       }
       $self->_print (">",$top,"\n",$str) or return;
       if ($seq->isa('Bio::Seq::MetaI')) {
           foreach my $meta ($seq->meta_names) {
               my $str = $seq->named_meta($meta);
               $str =~ s/(.{1,$width})/$1\n/g;
               $self->_print ("&",$meta,"\n",$str);
           }
       }
   }

   $self->flush if $self->_flush_on_write && defined $self->_fh;
   return 1;
}

=head2 width

 Title   : width
 Usage   : $obj->width($newval)
 Function: Get/Set the line width for METAFASTA output
 Returns : value of width
 Args    : newvalue (optional)


=cut

sub width{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'width'} = $value;
    }
    return $self->{'width'} || $WIDTH;
}

1;
