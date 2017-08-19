#
# Copyright (c) 1997-2001 bioperl, Chad Matsalla. All Rights Reserved.
#           This module is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Copyright Chad Matsalla
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::scf - .scf file input/output stream

=head1 SYNOPSIS

Do not use this module directly. Use it via the Bio::SeqIO class, see
L<Bio::SeqIO> for more information.

=head1 DESCRIPTION

This object can transform .scf files to and from Bio::Seq::SequenceTrace
objects.  Mechanisms are present to retrieve trace data from scf
files.

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
the bugs and their resolution.  Bug reports can be submitted via
the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR Chad Matsalla

Chad Matsalla
bioinformatics@dieselwurks.com

=head1 CONTRIBUTORS

Jason Stajich, jason@bioperl.org
Tony Cox, avc@sanger.ac.uk
Heikki Lehvaslaiho, heikki-at-bioperl-dot-org
Nancy Hansen, nhansen at mail.nih.gov

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::scf;
use vars qw($DEFAULT_QUALITY);
use strict;
use Bio::Seq::SeqFactory;
use Bio::Seq::SequenceTrace;
use Bio::Annotation::Comment;
use Dumpvalue;

my $dumper = Dumpvalue->new();
$dumper->veryCompact(1);

BEGIN {
    $DEFAULT_QUALITY= 10;
}

use base qw(Bio::SeqIO);

sub _initialize {
  my($self,@args) = @_;
  $self->SUPER::_initialize(@args);
  if( ! defined $self->sequence_factory ) {
      $self->sequence_factory(Bio::Seq::SeqFactory->new
                  (-verbose => $self->verbose(),
                   -type => 'Bio::Seq::Quality'));
  }
  binmode $self->_fh; # for the Win32/Mac crowds  
}

=head2 next_seq()

 Title   : next_seq()
 Usage   : $scf = $stream->next_seq()
 Function: returns the next scf sequence in the stream
 Returns : a Bio::Seq::SequenceTrace object
 Args    : NONE
 Notes   : Fills the interface specification for SeqIO.
            The SCF specification does not provide for having more then
           one sequence in a given scf. So once the filehandle has been open
           and passed to SeqIO do not expect to run this function more then
           once on a given scf unless you embraced and extended the SCF
       standard.  SCF comments are accessible through the Bio::SeqI
           interface method annotation().

=cut

#'
sub next_seq {
    my ($self) = @_;
    my ($seq, $seqc, $fh, $buffer, $offset, $length, $read_bytes, @read,
         %names);
    # set up a filehandle to read in the scf
    return if $self->{_readfile};
    $fh = $self->_fh();
    unless ($fh) {      # simulate the <> function
        if ( !fileno(ARGV) or eof(ARGV) ) {
            return unless my $ARGV = shift;
            open(ARGV,$ARGV) or
              $self->throw("Could not open $ARGV for SCF stream reading $!");
        }
        $fh = \*ARGV;
    }
    return unless read $fh, $buffer, 128; # no exception; probably end of file
    # now, the master data structure will be the creator
    my $creator;
    # he first thing to do is parse the header. This is common
    # among all versions of scf.
    # the rest of the the information is different between the
    # the different versions of scf.

    $creator->{header} = $self->_get_header($buffer);
    if ($creator->{header}->{'version'} lt "3.00") {
        $self->debug("scf.pm is working with a version 2 scf.\n");
        # first gather the trace information
        $length = $creator->{header}->{'samples'} *
          $creator->{header}->{sample_size}*4;
        $buffer = $self->read_from_buffer($fh, $buffer, $length,
                                                     $creator->{header}->{samples_offset});
        # @read = unpack "n$length",$buffer;
        # these traces need to be split
        # returns a reference to a hash
        $creator->{traces} = $self->_parse_v2_traces(
                                                     $buffer,$creator->{header}->{sample_size});
        # now go and get the base information
        $offset = $creator->{header}->{bases_offset};
        $length = ($creator->{header}->{bases} * 12);
        seek $fh,$offset,0;
        $buffer = $self->read_from_buffer($fh,$buffer,$length,$creator->{header}->{bases_offset});
        # now distill the information into its fractions.
        # the old way : $self->_set_v2_bases($buffer);
        # ref to an array, ref to a hash, string
        ($creator->{peak_indices},
         $creator->{qualities},
         $creator->{sequence},
         $creator->{accuracies}) = $self->_parse_v2_bases($buffer);

    } else {
        $self->debug("scf.pm is working with a version 3+ scf.\n");
        my $transformed_read;
        my $current_read_position = $creator->{header}->{sample_offset};
        $length = $creator->{header}->{'samples'}*
          $creator->{header}->{sample_size};
        # $dumper->dumpValue($creator->{header});
        foreach (qw(a c g t)) {
            $buffer = $self->read_from_buffer($fh,$buffer,$length,$current_read_position);
            my $byte = "n";
            if ($creator->{header}->{sample_size} == 1) {
                $byte = "c";
            }
            @read = unpack "${byte}${length}",$buffer;
            # this little spurt of nonsense is because
            # the trace values are given in the binary
            # file as unsigned shorts but they really
            # are signed deltas. 30000 is an arbitrary number
            # (will there be any traces with a given
            # point greater then 30000? I hope not.
            # once the read is read, it must be changed
            # from relative
            foreach (@read) {
                if ($_ > 30000) {
                    $_ -= 65536;
                }
            }
            $transformed_read = $self->_delta(\@read,"backward");
            # For 8-bit data we need to emulate a signed/unsigned
            # cast that is implicit in the C implementations.....
            if ($creator->{header}->{sample_size} == 1) {
                foreach (@{$transformed_read}) {
                    $_ += 256 if ($_ < 0);
                }
            }
            $current_read_position += $length;
            $creator->{'traces'}->{$_} = join(' ',@{$transformed_read});
        }
        
        # now go and get the peak index information
        $offset = $creator->{header}->{bases_offset};
        $length = ($creator->{header}->{bases} * 4);
        $buffer = $self->read_from_buffer($fh,$buffer,$length,$offset);
        $creator->{peak_indices} = $self->_get_v3_peak_indices($buffer);
        $offset += $length;
        # now go and get the accuracy information
        $buffer = $self->read_from_buffer($fh,$buffer,$length,$offset);
        $creator->{accuracies} = $self->_get_v3_base_accuracies($buffer);
        # OK, now go and get the base information.
        $offset += $length;
        $length = $creator->{header}->{bases};
        $buffer = $self->read_from_buffer($fh,$buffer,$length,$offset);
        $creator->{'sequence'} = unpack("a$length",$buffer);
        # now, finally, extract the calls from the accuracy information.
        $creator->{qualities} = $self->_get_v3_quality(
                                              $creator->{'sequence'},$creator->{accuracies});
    }
    # now go and get the comment information
    $offset = $creator->{header}->{comments_offset};
    seek $fh,$offset,0;
    $length = $creator->{header}->{comment_size};
    $buffer = $self->read_from_buffer($fh,$buffer,$length);
    $creator->{comments} = $self->_get_comments($buffer);
    my @name_comments = grep {$_->tagname() eq 'NAME'}
                $creator->{comments}->get_Annotations('comment');
    my $name_comment;
    if (@name_comments){
         $name_comment = $name_comments[0]->as_text();
         $name_comment =~ s/^Comment:\s+//;
    }

    my $swq = Bio::Seq::Quality->new(
        -seq  =>   $creator->{'sequence'},
        -qual =>    $creator->{'qualities'},
        -id   =>    $name_comment
                                              );
    my $returner = Bio::Seq::SequenceTrace->new(
                                           -swq      =>   $swq,
                                            -trace_a  =>   $creator->{'traces'}->{'a'},
                                            -trace_t  =>   $creator->{'traces'}->{'t'},
                                           -trace_g  =>   $creator->{'traces'}->{'g'},
                                           -trace_c  =>   $creator->{'traces'}->{'c'},
                                       -accuracy_a    => $creator->{'accuracies'}->{'a'},
                                   -accuracy_t    => $creator->{'accuracies'}->{'t'},
                                      -accuracy_g    => $creator->{'accuracies'}->{'g'},
                                    -accuracy_c    => $creator->{'accuracies'}->{'c'},
                                 -peak_indices  => $creator->{'peak_indices'}
                                                             );

        $returner->annotation($creator->{'comments'}); # add SCF comments
    $self->{'_readfile'} = 1;
    return $returner;
}


=head2 _get_v3_quality()

 Title   : _get_v3_quality()
 Usage   : $self->_get_v3_quality()
 Function: Set the base qualities from version3 scf
 Returns : Nothing. Alters $self.
 Args    : None.
 Notes   :

=cut

#'
sub _get_v3_quality {
    my ($self,$sequence,$accuracies) = @_;
    my @bases = split//,$sequence;
    my (@qualities,$currbase,$currqual,$counter);
    for ($counter=0; $counter <= $#bases ; $counter++) {
    $currbase = lc($bases[$counter]);
    if ($currbase eq "a") { $currqual = $accuracies->{'a'}->[$counter]; }
    elsif ($currbase eq "c") { $currqual = $accuracies->{'c'}->[$counter]; }
    elsif ($currbase eq "g") { $currqual = $accuracies->{'g'}->[$counter]; }
    elsif ($currbase eq "t") { $currqual = $accuracies->{'t'}->[$counter]; }
    else { $currqual = "unknown"; }
    push @qualities,$currqual;
    }
    return \@qualities;
}

=head2 _get_v3_peak_indices($buffer)

 Title   : _get_v3_peak_indices($buffer)
 Usage   : $self->_get_v3_peak_indices($buffer);
 Function: Unpacks the base accuracies for version3 scf
 Returns : Nothing. Alters $self
 Args    : A scalar containing binary data.
 Notes   :

=cut

sub _get_v3_peak_indices {
    my ($self,$buffer) = @_;
    my $length = length($buffer);
    my @read = unpack "N$length",$buffer;
     return join(' ',@read);
}

=head2 _get_v3_base_accuracies($buffer)

 Title   : _get_v3_base_accuracies($buffer)
 Usage   : $self->_get_v3_base_accuracies($buffer)
 Function: Set the base accuracies for version 3 scf's
 Returns : Nothing. Alters $self.
 Args    : A scalar containing binary data.
 Notes   :

=cut

#'
sub _get_v3_base_accuracies {
    my ($self,$buffer) = @_;
    my $length = length($buffer);
    my $qlength = $length/4;
    my $offset = 0;
    my (@qualities,@sorter,$counter,$round,$last_base,$accuracies,$currbase);
    foreach $currbase (qw(a c g t)) {
         my @read;
         $last_base = $offset + $qlength;
         for (;$offset < $last_base; $offset += $qlength) {
                    # a bioperler (perhaps me?) changed the unpack string to include 'n' rather than 'C'
                    # on 040322 I think that 'C' is correct. please email chad if you would like to accuse me of being incorrect
              @read = unpack "C$qlength", substr($buffer,$offset,$qlength);
              $accuracies->{$currbase} = \@read;
         }
    }
     return $accuracies;
}


=head2 _get_comments($buffer)

 Title   : _get_comments($buffer)
 Usage   : $self->_get_comments($buffer);
 Function: Gather the comments section from the scf and parse it into its
            components.
 Returns : a Bio::Annotation::Collection object
 Args    : The buffer. It is expected that the buffer contains a binary
            string for the comments section of an scf file according to
            the scf file specifications.
 Notes   :

=cut

sub _get_comments {
    my ($self,$buffer) = @_;
    my $comments = Bio::Annotation::Collection->new();
    my $size = length($buffer);
    my $comments_retrieved = unpack "a$size",$buffer;
    $comments_retrieved =~ s/\0//;
    my @comments_split = split/\n/,$comments_retrieved;
    if (@comments_split) {
        foreach (@comments_split) {
            /(\w+)=(.*)/;
            if ($1 && $2) {
                my ($tagname, $text) = ($1, $2);
                my $comment_obj = Bio::Annotation::Comment->new(
                                     -text => $text,
                                     -tagname => $tagname);

                $comments->add_Annotation('comment', $comment_obj);
            }
        }
    }
    $self->{'comments'} = $comments;
    return $comments;
}

=head2 _get_header()

 Title   : _get_header($buffer)
 Usage   : $self->_get_header($buffer);
 Function: Gather the header section from the scf and parse it into its
           components.
 Returns : Reference to a hash containing the header components.
 Args    : The buffer. It is expected that the buffer contains a binary
           string for the header section of an scf file according to the
           scf file specifications.
 Notes   : None.

=cut

sub _get_header {
    my ($self,$buffer) = @_;
    my $header;
    ($header->{'scf'},
     $header->{'samples'},
     $header->{'sample_offset'},
     $header->{'bases'},
     $header->{'bases_left_clip'},
     $header->{'bases_right_clip'},
     $header->{'bases_offset'},
     $header->{'comment_size'},
     $header->{'comments_offset'},
     $header->{'version'},
     $header->{'sample_size'},
     $header->{'code_set'},
     @{$header->{'header_spare'}} ) = unpack "a4 NNNNNNNN a4 NN N20", $buffer;

    $self->{'header'} = $header;
    return $header;
}

=head2 _parse_v2_bases($buffer)

 Title   : _parse_v2_bases($buffer)
 Usage   : $self->_parse_v2_bases($buffer);
 Function: Gather the bases section from the scf and parse it into its
           components.
 Returns :
 Args    : The buffer. It is expected that the buffer contains a binary
           string for the bases section of an scf file according to the
           scf file specifications.
 Notes   : None.

=cut

sub _parse_v2_bases {
    my ($self,$buffer) = @_;
    my $length = length($buffer);
    my ($offset2,$currbuff,$currbase,$currqual,$sequence,@qualities,@indices);
    my (@read,$harvester,$accuracies);
    for ($offset2=0;$offset2<$length;$offset2+=12) {
         @read = unpack "N C C C C a C3", substr($buffer,$offset2,$length);
         push @indices,$read[0];
         $currbase = lc($read[5]);
         if ($currbase eq "a") { $currqual = $read[1]; }
         elsif ($currbase eq "c") { $currqual = $read[2]; }
         elsif ($currbase eq "g") { $currqual = $read[3]; }
         elsif ($currbase eq "t") { $currqual = $read[4]; }
         else { $currqual = "UNKNOWN"; }
         push @{$accuracies->{"a"}},$read[1];
         push @{$accuracies->{"c"}},$read[2];
         push @{$accuracies->{"g"}},$read[3];
         push @{$accuracies->{"t"}},$read[4];

         $sequence .= $currbase;
         push @qualities,$currqual;
    }
     return (\@indices,\@qualities,$sequence,$accuracies)
}

=head2 _parse_v2_traces(\@traces_array)

 Title   : _pares_v2_traces(\@traces_array)
 Usage   : $self->_parse_v2_traces(\@traces_array);
 Function: Parses an scf Version2 trace array into its base components.
 Returns : Nothing. Modifies $self.
 Args    : A reference to an array of the unpacked traces section of an
           scf version2 file.

=cut

sub _parse_v2_traces {
    my ($self,$buffer,$sample_size) = @_;
     my $byte;
     if ($sample_size == 1) { $byte = "c"; }
     else { $byte = "n"; }
     my $length = CORE::length($buffer);
     my @read = unpack "${byte}${length}",$buffer;
          # this will be an array to the reference holding the array
     my $traces;
     my $array = 0;
     for (my $offset2 = 0; $offset2< scalar(@read); $offset2+=4) {
              push @{$traces->{'a'}},$read[$offset2];
              push @{$traces->{'c'}},$read[$offset2+1];
              push @{$traces->{'g'}},$read[$offset2+3];
              push @{$traces->{'t'}},$read[$offset2+2];
    }
    return $traces;
}


sub get_trace_deprecated_use_the_sequencetrace_object_instead {
    # my ($self,$base_channel,$traces) = @_;
    # $base_channel =~ tr/a-z/A-Z/;
    # if ($base_channel !~ /A|T|G|C/) {
    #   $self->throw("You tried to ask for a base channel that wasn't A,T,G, or C. Ask for one of those next time.");
    ##} elsif ($base_channel) {
     #  my @temp = split(' ',$self->{'traces'}->{$base_channel});
    #return \@temp;
    #}
}

sub _deprecated_get_peak_indices_deprecated_use_the_sequencetrace_object_instead {
    my ($self) = shift;
    my @temp = split(' ',$self->{'parsed'}->{'peak_indices'});
    return \@temp;
}


=head2 get_header()

 Title   : get_header()
 Usage   : %header = %{$obj->get_header()};
 Function: Return the header for this scf.
 Returns : A reference to a hash containing the header for this scf.
 Args    : None.
 Notes   :

=cut

sub get_header {
    my ($self) = shift;
    return $self->{'header'};
}

=head2 get_comments()

 Title   : get_comments()
 Usage   : %comments = %{$obj->get_comments()};
 Function: Return the comments for this scf.
 Returns : A Bio::Annotation::Collection object
 Args    : None.
 Notes   :

=cut

sub get_comments {
    my ($self) = shift;
    return $self->{'comments'};
}

sub _dump_traces_outgoing_deprecated_use_the_sequencetrace_object {
    my ($self,$transformed) = @_;
    my (@sA,@sT,@sG,@sC);
    if ($transformed) {
    @sA = @{$self->{'text'}->{'t_samples_a'}};
    @sC = @{$self->{'text'}->{'t_samples_c'}};
    @sG = @{$self->{'text'}->{'t_samples_g'}};
    @sT = @{$self->{'text'}->{'t_samples_t'}};
    }
    else {
    @sA = @{$self->{'text'}->{'samples_a'}};
    @sC = @{$self->{'text'}->{'samples_c'}};
    @sG = @{$self->{'text'}->{'samples_g'}};
    @sT = @{$self->{'text'}->{'samples_t'}};
    }
    print ("Count\ta\tc\tg\tt\n");
    for (my $curr=0; $curr < scalar(@sG); $curr++) {
    print("$curr\t$sA[$curr]\t$sC[$curr]\t$sG[$curr]\t$sT[$curr]\n");
    }
    return;
}

sub _dump_traces_incoming_deprecated_use_the_sequencetrace_object {
    # my ($self) = @_;
    # my (@sA,@sT,@sG,@sC);
    # @sA = @{$self->{'traces'}->{'A'}};
    # @sC = @{$self->{'traces'}->{'C'}};
    # @sG = @{$self->{'traces'}->{'G'}};
    # @sT = @{$self->{'traces'}->{'T'}};
    # @sA = @{$self->get_trace('A')};
    # @sC = @{$self->get_trace('C')};
    # @sG = @{$self->get_trace('G')};
    # @sT = @{$self->get_trace('t')};
    # print ("Count\ta\tc\tg\tt\n");
    # for (my $curr=0; $curr < scalar(@sG); $curr++) {
    #   print("$curr\t$sA[$curr]\t$sC[$curr]\t$sG[$curr]\t$sT[$curr]\n");
    #}
    #return;
}

=head2 write_seq

 Title   : write_seq(-target => $swq, <comments>)
 Usage   : $obj->write_seq(
               -target => $swq,
            -version => 2,
            -CONV => "Bioperl-Chads Mighty SCF writer.");
 Function: Write out an scf.
 Returns : Nothing.
 Args    : Requires: a reference to a Bio::Seq::Quality object to form the
           basis for the scf.
       if -version is provided, it should be "2" or "3". A SCF of that
       version will be written.
       Any other arguments are assumed to be comments and are put into
       the comments section of the scf. Read the specifications for scf
       to decide what might be good to put in here.

 Notes   :
          For best results, use a SequenceTrace object.
          The things that you need to write an scf:
          a) sequence
          b) quality
          c) peak indices
          d) traces
          - You _can_ write an scf with just a and b by passing in a
               Bio::Seq::Quality object- false traces will be synthesized
               for you.

=cut

sub write_seq {
    my ($self,%args) = @_;
    my %comments;
    my ($label,$arg);
    my ($swq) = $self->_rearrange([qw(TARGET)], %args);
     my $writer_fodder;
     if (ref($swq) =~ /Bio::Seq::SequenceTrace|Bio::Seq::Quality/) {
               if (ref($swq) eq "Bio::Seq::Quality") {
                         # this means that the object *has no trace data*
                         # we might as well synthesize some now, ok?
                    $swq = Bio::Seq::SequenceTrace->new(
                         -swq     =>   $swq
                    );
               }
     }
    else  {
    $self->throw("You must pass a Bio::Seq::Quality or a Bio::Seq::SequenceTrace object to write_seq as a parameter named \"target\"");
    }
          # all of the rest of the arguments are comments for the scf
    foreach $arg (sort keys %args) {
    next if ($arg =~ /target/i);
    ($label = $arg) =~ s/^\-//;
    $writer_fodder->{comments}->{$label} = $args{$arg};
    }
    if (!$comments{'NAME'}) { $comments{'NAME'} = $swq->id(); }
          # HA! Bwahahahaha.
    $writer_fodder->{comments}->{'CONV'} = "Bioperl-Chads Mighty SCF writer." unless defined $comments{'CONV'};
          # now deal with the version of scf they want to write
    if ($writer_fodder->{comments}->{version}) {
         if ($writer_fodder->{comments}->{version} != 2 && $writer_fodder->{comments}->{version} != 3) {
              $self->warn("This module can only write version 2.0 or 3.0 scf's. Writing a version 2.0 scf by default.");
              $writer_fodder->{header}->{version} = "2.00";
         }
         elsif ($writer_fodder->{comments}->{'version'} > 2) {
              $writer_fodder->{header}->{'version'} = "3.00";
         }
          else {
               $writer_fodder->{header}->{version} = "2";
          }
    }
    else {
         $writer_fodder->{header}->{'version'} = "3.00";
    }
          # set a few things in the header
    $writer_fodder->{'header'}->{'magic'} = ".scf";
    $writer_fodder->{'header'}->{'sample_size'} = "2";
    $writer_fodder->{'header'}->{'bases'} = length($swq->seq());
    $writer_fodder->{'header'}->{'bases_left_clip'} = "0";
    $writer_fodder->{'header'}->{'bases_right_clip'} = "0";
    $writer_fodder->{'header'}->{'sample_size'} = "2";
    $writer_fodder->{'header'}->{'code_set'} = "9";
    @{$writer_fodder->{'header'}->{'spare'}} = qw(0 0 0 0 0 0 0 0 0 0
                     0 0 0 0 0 0 0 0 0 0);
    $writer_fodder->{'header'}->{'samples_offset'} = "128";
     $writer_fodder->{'header'}->{'samples'} = $swq->trace_length();
          # create the binary for the comments and file it in writer_fodder
    $writer_fodder->{comments} =  $self->_get_binary_comments(
               $writer_fodder->{comments});
          # create the binary and the strings for the traces, bases,
          # offsets (if necessary), and accuracies (if necessary)
    $writer_fodder->{traces} = $self->_get_binary_traces(
               $writer_fodder->{'header'}->{'version'},
               $swq,$writer_fodder->{'header'}->{'sample_size'});
    my ($b_base_offsets,$b_base_accuracies,$samples_size,$bases_size);
    #
    # version 2
    #
    if ($writer_fodder->{'header'}->{'version'} == 2) {
          $writer_fodder->{bases} = $self->_get_binary_bases(
                         2,
                         $swq,
                         $writer_fodder->{'header'}->{'sample_size'});
         $samples_size = CORE::length($writer_fodder->{traces}->{'binary'});
         $bases_size = CORE::length($writer_fodder->{bases}->{binary});
         $writer_fodder->{'header'}->{'bases_offset'} = 128 + $samples_size;
         $writer_fodder->{'header'}->{'comments_offset'} = 128 +
               $samples_size + $bases_size;
         $writer_fodder->{'header'}->{'comments_size'} =
               length($writer_fodder->{'comments'}->{binary});
         $writer_fodder->{'header'}->{'private_size'} = "0";
         $writer_fodder->{'header'}->{'private_offset'} = 128 +
               $samples_size + $bases_size +
               $writer_fodder->{'header'}->{'comments_size'};
          $writer_fodder->{'header'}->{'binary'} =
          $self->_get_binary_header($writer_fodder->{header});
          $dumper->dumpValue($writer_fodder) if $self->verbose > 0;
         $self->_print ($writer_fodder->{'header'}->{'binary'})
               or print("Could not write binary header...\n");
         $self->_print ($writer_fodder->{'traces'}->{'binary'})
               or print("Could not write binary traces...\n");
         $self->_print ($writer_fodder->{'bases'}->{'binary'})
               or print("Could not write binary base structures...\n");
         $self->_print ($writer_fodder->{'comments'}->{'binary'})
               or print("Could not write binary comments...\n");
    }
    else {
          ($writer_fodder->{peak_indices},
           $writer_fodder->{accuracies},
           $writer_fodder->{bases},
           $writer_fodder->{reserved} ) =
               $self->_get_binary_bases(
                    3,
                    $swq,
                    $writer_fodder->{'header'}->{'sample_size'}
               );
         $writer_fodder->{'header'}->{'bases_offset'} = 128 +
               length($writer_fodder->{'traces'}->{'binary'});
         $writer_fodder->{'header'}->{'comments_size'} =
               length($writer_fodder->{'comments'}->{'binary'});
              # this is:
              # bases_offset + base_offsets + accuracies + called_bases +
               # reserved
         $writer_fodder->{'header'}->{'private_size'} = "0";

         $writer_fodder->{'header'}->{'comments_offset'} =
              128+length($writer_fodder->{'traces'}->{'binary'})+
                 length($writer_fodder->{'peak_indices'}->{'binary'})+
                 length($writer_fodder->{'accuracies'}->{'binary'})+
                length($writer_fodder->{'bases'}->{'binary'})+
                length($writer_fodder->{'reserved'}->{'binary'});
    $writer_fodder->{'header'}->{'private_offset'} =
          $writer_fodder->{'header'}->{'comments_offset'} +
               $writer_fodder->{'header'}->{'comments_size'};
    $writer_fodder->{'header'}->{'spare'}->[1] =
         $writer_fodder->{'header'}->{'comments_offset'} +
             length($writer_fodder->{'comments'}->{'binary'});
     $writer_fodder->{header}->{binary} =
          $self->_get_binary_header($writer_fodder->{header});
    $self->_print ($writer_fodder->{'header'}->{'binary'})
          or print("Couldn't write header\n");
    $self->_print ($writer_fodder->{'traces'}->{'binary'})
          or print("Couldn't write samples\n");
    $self->_print ($writer_fodder->{'peak_indices'}->{'binary'})
          or print("Couldn't write peak offsets\n");
    $self->_print ($writer_fodder->{'accuracies'}->{'binary'})
          or print("Couldn't write accuracies\n");
    $self->_print ($writer_fodder->{'bases'}->{'binary'})
          or print("Couldn't write called_bases\n");
    $self->_print ($writer_fodder->{'reserved'}->{'binary'})
          or print("Couldn't write reserved\n");
    $self->_print ($writer_fodder->{'comments'}->{'binary'})
          or print ("Couldn't write comments\n");
    }

    # kinda unnecessary, given the close() below, but maybe that'll go
    # away someday.
    $self->flush if $self->_flush_on_write && defined $self->_fh;

    $self->close();
    return 1;
}





=head2 _get_binary_header()

 Title   : _get_binary_header();
 Usage   : $self->_get_binary_header();
 Function: Provide the binary string that will be used as the header for
            a scfv2 document.
 Returns : A binary string.
 Args    : None. Uses the entries in the $self->{'header'} hash. These
            are set on construction of the object (hopefully correctly!).
 Notes   :

=cut

sub _get_binary_header {
    my ($self,$header) = @_;
    my $binary = pack "a4 NNNNNNNN a4 NN N20",
    (
     $header->{'magic'},
     $header->{'samples'},
     $header->{'samples_offset'},
     $header->{'bases'},
     $header->{'bases_left_clip'},
     $header->{'bases_right_clip'},
     $header->{'bases_offset'},
     $header->{'comments_size'},
     $header->{'comments_offset'},
     $header->{'version'},
     $header->{'sample_size'},
     $header->{'code_set'},
     @{$header->{'spare'}}
     );
    return $binary;
}

=head2 _get_binary_traces($version,$ref)

 Title   : _set_binary_tracesbases($version,$ref)
 Usage   : $self->_set_binary_tracesbases($version,$ref);
 Function: Constructs the trace and base strings for all scfs
 Returns : Nothing. Alters self.
 Args    : $version - "2" or "3"
       $sequence - a scalar containing arbitrary sequence data
       $ref - a reference to either a SequenceTraces or a
          SequenceWithQuality object.
 Notes   : This is a really complicated thing.

=cut

sub _get_binary_traces {
    my ($self,$version,$ref,$sample_size) = @_;
          # ref _should_ be a Bio::Seq::SequenceTrace, but might be a
          # Bio::Seq::Quality
     my $returner;
     my $sequence = $ref->seq();
     my $sequence_length = length($sequence);
          # first of all, do we need to synthesize the trace?
          # if so, call synthesize_base
     my ($traceobj,@traces,$current);
     if ( ref($ref) eq "Bio::Seq::Quality" ) {
          $traceobj = Bio::Seq::Quality->new(
               -target   =>   $ref
          );
          $traceobj->_synthesize_traces();
     }
     else {
          $traceobj = $ref;
          if ($version eq "2") {
               my $trace_length = $traceobj->trace_length();
               for ($current = 1; $current <= $trace_length; $current++) {
                    foreach (qw(a c g t)) {
                         push @traces,$traceobj->trace_value_at($_,$current);
                    }
               }
          }
          elsif ($version == 3) {
               foreach my $current_trace (qw(a c g t)) {
                    my @trace = @{$traceobj->trace($current_trace)};
                    foreach (@trace) {
                         if ($_ > 30000) {
                              $_ -= 65536;
                         }
                    }
                    my $transformed = $self->_delta(\@trace,"forward");
                    if($sample_size == 1){
                         foreach (@{$transformed}) {
                              $_ += 256 if ($_ < 0);
                         }
                    }
                    push @traces,@{$transformed};
               }
          }
     }
     $returner->{version} = $version;
     $returner->{string} = \@traces;
     my $length_of_traces = scalar(@traces);
     my $byte;
     if ($sample_size == 1) { $byte = "c"; } else { $byte = "n"; }
          # an unsigned integer should be I, but this is too long
          #
     $returner->{binary} = pack "n${length_of_traces}",@traces;
     $returner->{length} = CORE::length($returner->{binary});
     return $returner;
}


sub _get_binary_bases {
     my ($self,$version,$trace,$sample_size) = @_;
     my $byte;
     if ($sample_size == 1) { $byte = "c"; } else { $byte = "n"; }
     my ($returner,@current_row,$current_base,$string,$binary);
     my $length = $trace->length();
     if ($version == 2) {
          $returner->{'version'} = "2";
         for (my $current_base =1; $current_base <= $length; $current_base++) {
               my @current_row;
               push @current_row,$trace->peak_index_at($current_base);
               push @current_row,$trace->accuracy_at("a",$current_base);
               push @current_row,$trace->accuracy_at("c",$current_base);
               push @current_row,$trace->accuracy_at("g",$current_base);
               push @current_row,$trace->accuracy_at("t",$current_base);
               push @current_row,$trace->baseat($current_base);
               push @current_row,0,0,0;
               push @{$returner->{string}},@current_row;
               $returner->{binary} .= pack "N C C C C a C3",@current_row;
          }
          return $returner;
     }
     else {
          $returner->{'version'} = "3.00";
          $returner->{peak_indices}->{string} = $trace->peak_indices();
          my $length = scalar(@{$returner->{peak_indices}->{string}});
          $returner->{peak_indices}->{binary} =
               pack "N$length",@{$returner->{peak_indices}->{string}};
          $returner->{peak_indices}->{length} =
               CORE::length($returner->{peak_indices}->{binary});
          my @accuracies;
          foreach my $base (qw(a c g t)) {
               $returner->{accuracies}->{$base} = $trace->accuracies($base);
               push @accuracies,@{$trace->accuracies($base)};
          }
          $returner->{sequence} = $trace->seq();
          $length = scalar(@accuracies);
               # this really is "c" for samplesize == 2
          $returner->{accuracies}->{binary} = pack "C${length}",@accuracies;
          $returner->{accuracies}->{length} =
               CORE::length($returner->{accuracies}->{binary});
          $length = $trace->seq_obj()->length();
          for (my $count=0; $count< $length; $count++) {
               push @{$returner->{reserved}->{string}},0,0,0;
          }
     }
     $length = scalar(@{$returner->{reserved}->{string}});
               # this _must_ be "c"
     $returner->{'reserved'}->{'binary'} =
          pack "c$length",@{$returner->{reserved}->{string}};
     $returner->{'reserved'}->{'length'} =
          CORE::length($returner->{'reserved'}->{'binary'});
          # $returner->{'bases'}->{'string'} = $trace->seq();
     my @bases = split('',$trace->seq());
     $length = $trace->length();
     $returner->{'bases'}->{'binary'} = $trace->seq();
          # print("Returning this:\n");
          # $dumper->dumpValue($returner);
     return ($returner->{peak_indices},
             $returner->{accuracies},
             $returner->{bases},
             $returner->{reserved});

}


=head2 _make_trace_string($version)

 Title   : _make_trace_string($version)
 Usage   : $self->_make_trace_string($version)
 Function: Merges trace data for the four bases to produce an scf
       trace string. _requires_ $version
 Returns : Nothing. Alters $self.
 Args    : $version - a version number. "2" or "3"
 Notes   :

=cut

sub _make_trace_string {
    my ($self,$version) = @_;
    my @traces;
    my @traces_view;
    my @as = @{$self->{'text'}->{'samples_a'}};
    my @cs = @{$self->{'text'}->{'samples_c'}};
    my @gs = @{$self->{'text'}->{'samples_g'}};
    my @ts = @{$self->{'text'}->{'samples_t'}};
    if ($version == 2) {
        for (my $curr=0; $curr < scalar(@as); $curr++) {
        $as[$curr] = $DEFAULT_QUALITY unless defined $as[$curr];
        $cs[$curr] = $DEFAULT_QUALITY unless defined $cs[$curr];
        $gs[$curr] = $DEFAULT_QUALITY unless defined $gs[$curr];
        $ts[$curr] = $DEFAULT_QUALITY unless defined $ts[$curr];
        push @traces,($as[$curr],$cs[$curr],$gs[$curr],$ts[$curr]);
        }
    }
    elsif ($version == 3) {
        @traces = (@as,@cs,@gs,@ts);
    }
    else {
        $self->throw("No idea what version required to make traces here. You gave #$version#  Bailing.");
    }
    my $length = scalar(@traces);
    $self->{'text'}->{'samples_all'} = \@traces;

}

=head2 _get_binary_comments(\@comments)

 Title   : _get_binary_comments(\@comments)
 Usage   : $self->_get_binary_comments(\@comments);
 Function: Provide a binary string that will be the comments section of
       the scf file. See the scf specifications for detailed
       specifications for the comments section of an scf file. Hint:
       CODE=something\nBODE=something\n\0
 Returns :
 Args    : A reference to an array containing comments.
 Notes   : None.

=cut

sub _get_binary_comments {
    my ($self,$rcomments) = @_;
     my $returner;
    my $comments_string = '';
    my %comments = %$rcomments;
    foreach my $key (sort keys %comments) {
    $comments{$key} ||= '';
    $comments_string .= "$key=$comments{$key}\n";
    }
    $comments_string .= "\n\0";
     my $length = CORE::length($comments_string);
     $returner->{length} = $length;
     $returner->{string} = $comments_string;
     $returner->{binary} = pack "A$length",$comments_string;
     return $returner;
}

#=head2 _fill_missing_data($swq)
#
# Title   : _fill_missing_data($swq)
# Usage   : $self->_fill_missing_data($swq);
# Function: If the $swq with quality has no qualities, set all qualities
#      to 0.
#      If the $swq has no sequence, set the sequence to N's.
# Returns : Nothing. Modifies the Bio::Seq::Quality that was passed as an
#      argument.
# Args    : A reference to a Bio::Seq::Quality
# Notes   : None.
#
#=cut
#
##'
#sub _fill_missing_data {
#    my ($self,$swq) = @_;
#    my $qual_obj = $swq->qual_obj();
#    my $seq_obj = $swq->seq_obj();
#    if ($qual_obj->length() == 0 && $seq_obj->length() != 0) {
#   my $fake_qualities = ("$DEFAULT_QUALITY ")x$seq_obj->length();
#   $swq->qual($fake_qualities);
#    }
#    if ($seq_obj->length() == 0 && $qual_obj->length != 0) {
#   my $sequence = ("N")x$qual_obj->length();
#   $swq->seq($sequence);
#    }
#}

=head2 _delta(\@trace_data,$direction)

 Title   : _delta(\@trace_data,$direction)
 Usage   : $self->_delta(\@trace_data,$direction);
 Function:
 Returns : A reference to an array containing modified trace values.
 Args    : A reference to an array containing trace data and a string
       indicating the direction of conversion. ("forward" or
       "backward").
 Notes   : This code is taken from the specification for SCF3.2.
       http://www.mrc-lmb.cam.ac.uk/pubseq/manual/formats_unix_4.html

=cut


sub _delta {
    my ($self,$rsamples,$direction) = @_;
    my @samples = @$rsamples;
        # /* If job == DELTA_IT:
        # *  change a series of sample points to a series of delta delta values:
        # *  ie change them in two steps:
        # *  first: delta = current_value - previous_value
        # *  then: delta_delta = delta - previous_delta
        # * else
        # *  do the reverse
        # */
        # int i;
        # uint_2 p_delta, p_sample;

    my ($i,$num_samples,$p_delta,$p_sample,@samples_converted,$p_sample1,$p_sample2);
        my $SLOW_BUT_CLEAR = 0;
        $num_samples = scalar(@samples);
    # c-programmers are funny people with their single-letter variables

    if ( $direction eq "forward" ) {
            if($SLOW_BUT_CLEAR){
        $p_delta  = 0;
        for ($i=0; $i < $num_samples; $i++) {
            $p_sample = $samples[$i];
            $samples[$i] = $samples[$i] - $p_delta;
            $p_delta  = $p_sample;
        }
        $p_delta  = 0;
        for ($i=0; $i < $num_samples; $i++) {
            $p_sample = $samples[$i];
            $samples[$i] = $samples[$i] - $p_delta;
            $p_delta  = $p_sample;
        }
            } else {
                for ($i = $num_samples-1; $i > 1; $i--){
                    $samples[$i] = $samples[$i] - 2*$samples[$i-1] + $samples[$i-2];
                }
                $samples[1] = $samples[1] - 2*$samples[0];
            }
    }
    elsif ($direction eq "backward") {
            if($SLOW_BUT_CLEAR){
        $p_sample = 0;
        for ($i=0; $i < $num_samples; $i++) {
            $samples[$i] = $samples[$i] + $p_sample;
            $p_sample = $samples[$i];
        }
        $p_sample = 0;
        for ($i=0; $i < $num_samples; $i++) {
            $samples[$i] = $samples[$i] + $p_sample;
            $p_sample = $samples[$i];
        }
            } else {
                $p_sample1 = $p_sample2 = 0;
                for ($i = 0; $i < $num_samples; $i++){
                    $p_sample1 = $p_sample1 + $samples[$i];
                    $samples[$i] = $p_sample1 + $p_sample2;
                    $p_sample2 = $samples[$i];
                }

            }
    }
    else {
        $self->warn("Bad direction. Use \"forward\" or \"backward\".");
    }
    return \@samples;
}

=head2 _unpack_magik($buffer)

 Title   : _unpack_magik($buffer)
 Usage   : $self->_unpack_magik($buffer)
 Function: What unpack specification should be used? Try them all.
 Returns : Nothing.
 Args    : A buffer containing arbitrary binary data.
 Notes   : Eliminate the ambiguity and the guesswork. Used in the
       adaptation of _delta(), mostly.

=cut

sub _unpack_magik {
    my ($self,$buffer) = @_;
    my $length = length($buffer);
    my (@read,$counter);
    foreach (qw(c C s S i I l L n N v V)) {
        @read = unpack "$_$length", $buffer;
        for ($counter=0; $counter < 20; $counter++) {
            print("$read[$counter]\n");
        }
    }
}

=head2 read_from_buffer($filehandle,$buffer,$length)

 Title   : read_from_buffer($filehandle,$buffer,$length)
 Usage   : $self->read_from_buffer($filehandle,$buffer,$length);
 Function: Read from the buffer.
 Returns : $buffer, containing a read of $length
 Args    : a filehandle, a buffer, and a read length
 Notes   : I just got tired of typing
       "unless (length($buffer) == $length)" so I put it here.

=cut

sub read_from_buffer {
    my ($self,$fh,$buffer,$length,$start_position) = @_;
          # print("Reading from a buffer!!! length($length) ");
     if ($start_position) {
               # print(" startposition($start_position)(".sprintf("%X", $start_position).")\n");
     }
          # print("\n");
     if ($start_position) {
               # print("seeking to this position in the file: (".$start_position.")\n");
          seek ($fh,$start_position,0);
               # print("done. here is where I am now: (".tell($fh).")\n");
     }
     else {
          # print("You did not specify a start position. Going from this position (the current position) (".tell($fh).")\n");
     }
    read $fh, $buffer, $length;
    unless (length($buffer) == $length) {
        $self->warn("The read was incomplete! Trying harder.");
        my $missing_length = $length - length($buffer);
        my $buffer2;
        read $fh,$buffer2,$missing_length;
        $buffer .= $buffer2;
        if (length($buffer) != $length) {
            $self->throw("Unexpected end of file while reading from SCF file. I should have read $length but instead got ".length($buffer)."! Current file position is ".tell($fh).".");
        }
    }

    return $buffer;
}

=head2 _dump_keys()

 Title   : _dump_keys()
 Usage   : &_dump_keys($a_reference_to_some_hash)
 Function: Dump out the keys in a hash.
 Returns : Nothing.
 Args    : A reference to a hash.
 Notes   : A debugging method.

=cut

sub _dump_keys {
    my $rhash = shift;
    if ($rhash !~ /HASH/) {
        print("_dump_keys: that was not a hash.\nIt was #$rhash# which was this reference:".ref($rhash)."\n");
        return;
    }
    print("_dump_keys: The keys for $rhash are:\n");
    foreach (sort keys %$rhash) {
        print("$_\n");
    }
}

=head2 _dump_base_accuracies()

 Title   : _dump_base_accuracies()
 Usage   : $self->_dump_base_accuracies();
 Function: Dump out the v3 base accuracies in an easy to read format.
 Returns : Nothing.
 Args    : None.
 Notes   : A debugging method.

=cut

sub _dump_base_accuracies {
    my $self = shift;
    print("Dumping base accuracies! for v3\n");
    print("There are this many elements in a,c,g,t:\n");
    print(scalar(@{$self->{'text'}->{'v3_base_accuracy_a'}}).",".scalar(@{$self->{'text'}->{'v3_base_accuracy_c'}}).",".scalar(@{$self->{'text'}->{'v3_base_accuracy_g'}}).",".scalar(@{$self->{'text'}->{'v3_base_accuracy_t'}})."\n");
    my $number_traces = scalar(@{$self->{'text'}->{'v3_base_accuracy_a'}});
    for (my $counter=0; $counter < $number_traces; $counter++ ) {
        print("$counter\t");
        print $self->{'text'}->{'v3_base_accuracy_a'}->[$counter]."\t";
        print $self->{'text'}->{'v3_base_accuracy_c'}->[$counter]."\t";
        print $self->{'text'}->{'v3_base_accuracy_g'}->[$counter]."\t";
        print $self->{'text'}->{'v3_base_accuracy_t'}->[$counter]."\t";
        print("\n");
    }
}

=head2 _dump_peak_indices_incoming()

 Title   : _dump_peak_indices_incoming()
 Usage   : $self->_dump_peak_indices_incoming();
 Function: Dump out the v3 peak indices in an easy to read format.
 Returns : Nothing.
 Args    : None.
 Notes   : A debugging method.

=cut

sub _dump_peak_indices_incoming {
    my $self = shift;
    print("Dump peak indices incoming!\n");
    my $length = $self->{'bases'};
    print("The length is $length\n");
    for (my $count=0; $count < $length; $count++) {
        print("$count\t$self->{parsed}->{peak_indices}->[$count]\n");
    }
}

=head2 _dump_base_accuracies_incoming()

 Title   : _dump_base_accuracies_incoming()
 Usage   : $self->_dump_base_accuracies_incoming();
 Function: Dump out the v3 base accuracies in an easy to read format.
 Returns : Nothing.
 Args    : None.
 Notes   : A debugging method.

=cut

sub _dump_base_accuracies_incoming {
    my $self = shift;
    print("Dumping base accuracies! for v3\n");
        # print("There are this many elements in a,c,g,t:\n");
        # print(scalar(@{$self->{'parsed'}->{'v3_base_accuracy_a'}}).",".scalar(@{$self->{'text'}->{'v3_base_accuracy_c'}}).",".scalar(@{$self->{'text'}->{'v3_base_accuracy_g'}}).",".scalar(@{$self->{'text'}->{'v3_base_accuracy_t'}})."\n");
    my $number_traces = $self->{'bases'};
    for (my $counter=0; $counter < $number_traces; $counter++ ) {
        print("$counter\t");
        foreach (qw(A T G C)) {
            print $self->{'parsed'}->{'base_accuracies'}->{$_}->[$counter]."\t";
        }
        print("\n");
    }
}


=head2 _dump_comments()

 Title   : _dump_comments()
 Usage   : $self->_dump_comments();
 Function: Debug dump the comments section from the scf.
 Returns : Nothing.
 Args    : Nothing.
 Notes   : None.

=cut

sub _dump_comments {
    my ($self) = @_;
    warn ("SCF comments:\n");
    foreach my $k (keys %{$self->{'comments'}}) {
    warn ("\t {$k} ==> ", $self->{'comments'}->{$k}, "\n");
    }
}



1;
__END__


