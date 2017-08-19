# BioPerl module for Bio::SeqIO::abi
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Aaron Mackey <amackey@virginia.edu>
#
# Copyright Aaron Mackey
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::abi - abi trace sequence input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from abi trace
files.  To optionally read the trace graph data (which can be used
to draw chromatographs, for instance), set the optional
'-get_trace_data' flag or the get_trace_data method to a value
evaluating to TRUE.

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
the bugs and their resolution.
Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHORS - Aaron Mackey

Email: amackey@virginia.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::abi;
use vars qw(@ISA $READ_AVAIL);
use strict;

use Bio::SeqIO;
use Bio::Seq::SeqFactory;

push @ISA, qw( Bio::SeqIO );

sub BEGIN {
    eval { require Bio::SeqIO::staden::read; };
    if ($@) {
	$READ_AVAIL = 0;
    } else {
	push @ISA, "Bio::SeqIO::staden::read";
	$READ_AVAIL = 1;
    }
}

sub _initialize {
  my($self,@args) = @_;
  $self->SUPER::_initialize(@args);
  my ($get_trace) = $self->_rearrange([qw(get_trace_data)],@args);
  $get_trace && $self->get_trace_data(1);
  if( ! defined $self->sequence_factory ) {
      $self->sequence_factory(Bio::Seq::SeqFactory->new(-verbose => $self->verbose(), -type => 'Bio::Seq::Quality'));
  }
  unless ($READ_AVAIL) {
      Bio::Root::Root->throw( -class => 'Bio::Root::SystemException',
			      -text  => "Bio::SeqIO::staden::read is not available; make sure the bioperl-ext package has been installed successfully!"
			    );
  }
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq::Quality object
 Args    : NONE

=cut

sub next_seq {

    my ($self) = @_;

    my ($seq, $id, $desc, $qual) = $self->read_trace($self->_fh, 'abi');

    # create the seq object
	my ($base_locs, $a_trace, $c_trace, $g_trace, $t_trace, $points, $max_height);
	if ($self->get_trace_data) {
		($base_locs, $a_trace, $c_trace, $g_trace, $t_trace, $points, $max_height) = $self->read_trace_with_graph($self->_fh, 'abi');
	} else {
		$base_locs = [];
	}

    # create the seq object
    $seq = $self->sequence_factory->create(-seq        => $seq,
					   -id         => $id,
					   -primary_id => $id,
					   -desc       => $desc,
					   -alphabet   => 'DNA',
					   -qual       => $qual,
					   -trace      => join (" ", @{$base_locs}),
					   -trace_data => { a_trace => $a_trace,
									   c_trace => $c_trace,
									   g_trace => $g_trace,
									   t_trace => $t_trace, 
					   		    max_height => $max_height,
								num_points => $points }
					   );
    return $seq;
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq(@seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq object


=cut

sub write_seq {
    my ($self,@seq) = @_;

    my $fh = $self->_fh;
    foreach my $seq (@seq) {
	$self->write_trace($fh, $seq, 'abi');
    }

    $self->flush if $self->_flush_on_write && defined $self->_fh;
    return 1;
}

=head2 get_trace_data

 Title   : get_trace_data
 Usage   : $stream->get_trace_data(1)
 Function: set boolean flag to retrieve the trace data (possibly for
           output)
 Returns : bool value, TRUE = retrieve trace data (default FALSE)
 Args    : bool value

=cut

sub get_trace_data {
	my ($self, $val) = @_;
	$self->{_get_trace_data} = $val ? 1 : 0 if (defined $val);
	$self->{_get_trace_data};
}

1;
