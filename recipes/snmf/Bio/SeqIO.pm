# BioPerl module for Bio::SeqIO
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#       and Lincoln Stein  <lstein@cshl.org>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself
#
# _history
# October 18, 1999  Largely rewritten by Lincoln Stein

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO - Handler for SeqIO Formats

=head1 SYNOPSIS

    use Bio::SeqIO;

    $in  = Bio::SeqIO->new(-file => "inputfilename" ,
                           -format => 'Fasta');
    $out = Bio::SeqIO->new(-file => ">outputfilename" ,
                           -format => 'EMBL');

    while ( my $seq = $in->next_seq() ) {
        $out->write_seq($seq);
    }

  # Now, to actually get at the sequence object, use the standard Bio::Seq
  # methods (look at Bio::Seq if you don't know what they are)

    use Bio::SeqIO;

    $in  = Bio::SeqIO->new(-file => "inputfilename" ,
                           -format => 'genbank');

    while ( my $seq = $in->next_seq() ) {
       print "Sequence ",$seq->id, " first 10 bases ",
             $seq->subseq(1,10), "\n";
    }


  # The SeqIO system does have a filehandle binding. Most people find this
  # a little confusing, but it does mean you can write the world's
  # smallest reformatter

    use Bio::SeqIO;

    $in  = Bio::SeqIO->newFh(-file => "inputfilename" ,
                             -format => 'Fasta');
    $out = Bio::SeqIO->newFh(-format => 'EMBL');

    # World's shortest Fasta<->EMBL format converter:
    print $out $_ while <$in>;


=head1 DESCRIPTION

Bio::SeqIO is a handler module for the formats in the SeqIO set (eg,
Bio::SeqIO::fasta). It is the officially sanctioned way of getting at
the format objects, which most people should use.

The Bio::SeqIO system can be thought of like biological file handles.
They are attached to filehandles with smart formatting rules (eg,
genbank format, or EMBL format, or binary trace file format) and
can either read or write sequence objects (Bio::Seq objects, or
more correctly, Bio::SeqI implementing objects, of which Bio::Seq is
one such object). If you want to know what to do with a Bio::Seq
object, read L<Bio::Seq>.

The idea is that you request a stream object for a particular format.
All the stream objects have a notion of an internal file that is read
from or written to. A particular SeqIO object instance is configured
for either input or output. A specific example of a stream object is
the Bio::SeqIO::fasta object.

Each stream object has functions

   $stream->next_seq();

and

   $stream->write_seq($seq);

As an added bonus, you can recover a filehandle that is tied to the
SeqIO object, allowing you to use the standard E<lt>E<gt> and print
operations to read and write sequence objects:

    use Bio::SeqIO;

    $stream = Bio::SeqIO->newFh(-format => 'Fasta',
                                -fh     => \*ARGV);
    # read from standard input or the input filenames

    while ( $seq = <$stream> ) {
        # do something with $seq
    }

and

    print $stream $seq; # when stream is in output mode

This makes the simplest ever reformatter

    #!/usr/bin/perl
    use strict;
    my $format1 = shift;
    my $format2 = shift || die
       "Usage: reformat format1 format2 < input > output";

    use Bio::SeqIO;

    my $in  = Bio::SeqIO->newFh(-format => $format1, -fh => \*ARGV );
    my $out = Bio::SeqIO->newFh(-format => $format2 );
    # Note: you might want to quote -format to keep older
    # perl's from complaining.

    print $out $_ while <$in>;


=head1 CONSTRUCTORS

=head2 Bio::SeqIO-E<gt>new()

   $seqIO = Bio::SeqIO->new(-file   => 'seqs.fasta', -format => $format);
   $seqIO = Bio::SeqIO->new(-fh     => \*FILEHANDLE, -format => $format);
   $seqIO = Bio::SeqIO->new(-string => $string     , -format => $format);
   $seqIO = Bio::SeqIO->new(-format => $format);

The new() class method constructs a new Bio::SeqIO object. The returned object
can be used to retrieve or print Seq objects. new() accepts the following
parameters:

=over 5

=item -file

A file path to be opened for reading or writing.  The usual Perl
conventions apply:

   'file'       # open file for reading
   '>file'      # open file for writing
   '>>file'     # open file for appending
   '+<file'     # open file read/write
   'command |'  # open a pipe from the command
   '| command'  # open a pipe to the command

=item -fh

You may use new() with a opened filehandle, provided as a glob reference. For
example, to read from STDIN:

   my $seqIO = Bio::SeqIO->new(-fh => \*STDIN);

A string filehandle is handy if you want to modify the output in the
memory, before printing it out. The following program reads in EMBL
formatted entries from a file and prints them out in fasta format with
some HTML tags:

  use Bio::SeqIO;
  use IO::String;
  my $in = Bio::SeqIO->new(-file => "emblfile",
                           -format => 'EMBL');
  while ( my $seq = $in->next_seq() ) {
      # the output handle is reset for every file
      my $stringio = IO::String->new($string);
      my $out = Bio::SeqIO->new(-fh => $stringio,
                                -format => 'fasta');
      # output goes into $string
      $out->write_seq($seq);
      # modify $string
      $string =~ s|(>)(\w+)|$1<font color="Red">$2</font>|g;
      # print into STDOUT
      print $string;
  }

=item -string

A string to read the sequences from. For example:

   my $string = ">seq1\nACGCTAGCTAGC\n";
   my $seqIO = Bio::SeqIO->new(-string => $string);

=item -format

Specify the format of the file.  Supported formats include fasta,
genbank, embl, swiss (SwissProt), Entrez Gene and tracefile formats
such as abi (ABI) and scf. There are many more, for a complete listing
see the SeqIO HOWTO (L<http://bioperl.open-bio.org/wiki/HOWTO:SeqIO>).

If no format is specified and a filename is given then the module will
attempt to deduce the format from the filename suffix. If there is no
suffix that Bioperl understands then it will attempt to guess the
format based on file content. If this is unsuccessful then SeqIO will 
throw a fatal error.

The format name is case-insensitive: 'FASTA', 'Fasta' and 'fasta' are
all valid.

Currently, the tracefile formats (except for SCF) require installation
of the external Staden "io_lib" package, as well as the
Bio::SeqIO::staden::read package available from the bioperl-ext
repository.

=item -alphabet

Sets the alphabet ('dna', 'rna', or 'protein'). When the alphabet is
set then Bioperl will not attempt to guess what the alphabet is. This
may be important because Bioperl does not always guess correctly.

=item -flush

By default, all files (or filehandles) opened for writing sequences
will be flushed after each write_seq() (making the file immediately
usable).  If you do not need this facility and would like to marginally
improve the efficiency of writing multiple sequences to the same file
(or filehandle), pass the -flush option '0' or any other value that
evaluates as defined but false:

  my $gb = Bio::SeqIO->new(-file   => "<gball.gbk",
                           -format => "gb");
  my $fa = Bio::SeqIO->new(-file   => ">gball.fa",
                           -format => "fasta",
                           -flush  => 0); # go as fast as we can!
  while($seq = $gb->next_seq) { $fa->write_seq($seq) }

=item -seqfactory

Provide a Bio::Factory::SequenceFactoryI object. See the sequence_factory() method.

=item -locfactory

Provide a Bio::Factory::LocationFactoryI object. See the location_factory() method.

=item -objbuilder

Provide a Bio::Factory::ObjectBuilderI object. See the object_builder() method.

=back

=head2 Bio::SeqIO-E<gt>newFh()

   $fh = Bio::SeqIO->newFh(-fh => \*FILEHANDLE, -format=>$format);
   $fh = Bio::SeqIO->newFh(-format => $format);
   # etc.

This constructor behaves like new(), but returns a tied filehandle
rather than a Bio::SeqIO object.  You can read sequences from this
object using the familiar E<lt>E<gt> operator, and write to it using
print().  The usual array and $_ semantics work.  For example, you can
read all sequence objects into an array like this:

  @sequences = <$fh>;

Other operations, such as read(), sysread(), write(), close(), and
printf() are not supported.

=head1 OBJECT METHODS

See below for more detailed summaries.  The main methods are:

=head2 $sequence = $seqIO-E<gt>next_seq()

Fetch the next sequence from the stream, or nothing if no more.

=head2 $seqIO-E<gt>write_seq($sequence [,$another_sequence,...])

Write the specified sequence(s) to the stream.

=head2 TIEHANDLE(), READLINE(), PRINT()

These provide the tie interface.  See L<perltie> for more details.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.

Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support 

Please direct usage questions or support issues to the mailing list:

 bioperl-l@bioperl.org

rather than to the module maintainer directly. Many experienced and 
responsive experts will be able look at the problem and quickly 
address it. Please include a thorough description of the problem 
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via the
web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Ewan Birney, Lincoln Stein

Email birney@ebi.ac.uk
      lstein@cshl.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

#' Let the code begin...

package Bio::SeqIO;

use strict;
use warnings;

use Bio::Factory::FTLocationFactory;
use Bio::Seq::SeqBuilder;
use Bio::Tools::GuessSeqFormat;
use Symbol;

use parent qw(Bio::Root::Root Bio::Root::IO Bio::Factory::SequenceStreamI);

my %valid_alphabet_cache;


=head2 new

 Title   : new
 Usage   : $stream = Bio::SeqIO->new(-file => 'sequences.fasta',
                                     -format => 'fasta');
 Function: Returns a new sequence stream
 Returns : A Bio::SeqIO stream initialised with the appropriate format
 Args    : Named parameters indicating where to read the sequences from or to
           write them to:
             -file   => filename, OR
             -fh     => filehandle to attach to, OR
             -string => string

           Additional arguments, all with reasonable defaults:
             -format     => format of the sequences, usually auto-detected
             -alphabet   => 'dna', 'rna', or 'protein'
             -flush      => 0 or 1 (default: flush filehandles after each write)
             -seqfactory => sequence factory
             -locfactory => location factory
             -objbuilder => object builder

See L<Bio::SeqIO::Handler>

=cut

my $entry = 0;

sub new {
    my ($caller, @args) = @_;
    my $class = ref($caller) || $caller;

    # or do we want to call SUPER on an object if $caller is an
    # object?
    if( $class =~ /Bio::SeqIO::(\S+)/ ) {
        my ($self) = $class->SUPER::new(@args);
        $self->_initialize(@args);
        return $self;
    } else {
        my %params = @args;
        @params{ map { lc $_ } keys %params } = values %params; # lowercase keys

        unless( defined $params{-file} ||
                defined $params{-fh}   ||
                defined $params{-string} ) {
            $class->throw("file argument provided, but with an undefined value") 
                if exists $params{'-file'};
            $class->throw("fh argument provided, but with an undefined value") 
                if exists $params{'-fh'};
            $class->throw("string argument provided, but with an undefined value") 
                if exists($params{'-string'});
            # $class->throw("No file, fh, or string argument provided"); # neither defined
        }

        # Determine or guess sequence format and variant
        my $format = $params{'-format'};
        if (! $format ) {
            if ($params{-file}) {
                # Guess from filename extension, and then from file content
                $format = $class->_guess_format( $params{-file} ) ||
                          Bio::Tools::GuessSeqFormat->new(-file => $params{-file}  )->guess;
            } elsif ($params{-fh}) {
                # Guess from filehandle content
                $format = Bio::Tools::GuessSeqFormat->new(-fh   => $params{-fh}    )->guess;
            } elsif ($params{-string}) {
                # Guess from string content
                $format = Bio::Tools::GuessSeqFormat->new(-text => $params{-string})->guess;
            }
        }

        # changed 1-3-11; no need to print out an empty string (only way this
        # exception is triggered) - cjfields
        $class->throw("Could not guess format from file, filehandle or string")
            if not $format;
        $format = "\L$format";  # normalize capitalization to lower case

        if ($format =~ /-/) {
            ($format, my $variant) = split('-', $format, 2);
            $params{-variant} = $variant;
        }

        return unless( $class->_load_format_module($format) );
        return "Bio::SeqIO::$format"->new(%params);
    }
}


=head2 newFh

 Title   : newFh
 Usage   : $fh = Bio::SeqIO->newFh(-file=>$filename,-format=>'Format')
 Function: Does a new() followed by an fh()
 Example : $fh = Bio::SeqIO->newFh(-file=>$filename,-format=>'Format')
           $sequence = <$fh>;   # read a sequence object
           print $fh $sequence; # write a sequence object
 Returns : filehandle tied to the Bio::SeqIO::Fh class
 Args    :

See L<Bio::SeqIO::Fh>

=cut

sub newFh {
    my $class = shift;
    return unless my $self = $class->new(@_);
    return $self->fh;
}


=head2 fh

 Title   : fh
 Usage   : $obj->fh
 Function: Get or set the IO filehandle
 Example : $fh = $obj->fh;      # make a tied filehandle
           $sequence = <$fh>;   # read a sequence object
           print $fh $sequence; # write a sequence object
 Returns : filehandle tied to Bio::SeqIO class
 Args    : none

=cut

sub fh {
    my $self = shift;
    my $class = ref($self) || $self;
    my $s = Symbol::gensym;
    tie $$s,$class,$self;
    return $s;
}


# _initialize is chained for all SeqIO classes

sub _initialize {
    my($self, @args) = @_;

    # flush is initialized by the Root::IO init

    my ($seqfact,$locfact,$objbuilder, $alphabet) =
        $self->_rearrange([qw(SEQFACTORY
                              LOCFACTORY
                              OBJBUILDER
                              ALPHABET)
                                         ], @args);

    $locfact = Bio::Factory::FTLocationFactory->new(-verbose => $self->verbose)
        if ! $locfact;
    $objbuilder = Bio::Seq::SeqBuilder->new(-verbose => $self->verbose)
        unless $objbuilder;
    $self->sequence_builder($objbuilder);
    $self->location_factory($locfact);

    # note that this should come last because it propagates the sequence
    # factory to the sequence builder
    $seqfact && $self->sequence_factory($seqfact);
        
    #bug 2160
    $alphabet && $self->alphabet($alphabet);

    # initialize the IO part
    $self->_initialize_io(@args);
}


=head2 next_seq

 Title   : next_seq
 Usage   : $seq = stream->next_seq
 Function: Reads the next sequence object from the stream and returns it.

           Certain driver modules may encounter entries in the stream
           that are either misformatted or that use syntax not yet
           understood by the driver. If such an incident is
           recoverable, e.g., by dismissing a feature of a feature
           table or some other non-mandatory part of an entry, the
           driver will issue a warning. In the case of a
           non-recoverable situation an exception will be thrown.  Do
           not assume that you can resume parsing the same stream
           after catching the exception. Note that you can always turn
           recoverable errors into exceptions by calling
           $stream->verbose(2).

 Returns : a Bio::Seq sequence object, or nothing if no more sequences
           are available

 Args    : none

See L<Bio::Root::RootI>, L<Bio::Factory::SeqStreamI>, L<Bio::Seq>

=cut

sub next_seq {
   my ($self, $seq) = @_;
   $self->throw("Sorry, you cannot read from a generic Bio::SeqIO object.");
}


=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq object

=cut

sub write_seq {
    my ($self, $seq) = @_;
    $self->throw("Sorry, you cannot write to a generic Bio::SeqIO object.");
}


=head2 format

 Title   : format
 Usage   : $format = $stream->format()
 Function: Get the sequence format
 Returns : sequence format, e.g. fasta, fastq
 Args    : none

=cut

# format() method inherited from Bio::Root::IO


=head2 alphabet

 Title   : alphabet
 Usage   : $self->alphabet($newval)
 Function: Set/get the molecule type for the Seq objects to be created.
 Example : $seqio->alphabet('protein')
 Returns : value of alphabet: 'dna', 'rna', or 'protein'
 Args    : newvalue (optional)
 Throws  : Exception if the argument is not one of 'dna', 'rna', or 'protein'

=cut

sub alphabet {
   my ($self, $value) = @_;

   if ( defined $value) {
        $value = lc $value;
        unless ($valid_alphabet_cache{$value}) {
            # instead of hard-coding the allowed values once more, we check by
            # creating a dummy sequence object
            eval {
                require Bio::PrimarySeq;
                my $seq = Bio::PrimarySeq->new( -verbose  => $self->verbose,
                                                -alphabet => $value          );
            };
            if ($@) {
                $self->throw("Invalid alphabet: $value\n. See Bio::PrimarySeq for allowed values.");
            }
            $valid_alphabet_cache{$value} = 1;
        }
        $self->{'alphabet'} = $value;
   }
   return $self->{'alphabet'};
}


=head2 _load_format_module

 Title   : _load_format_module
 Usage   : *INTERNAL SeqIO stuff*
 Function: Loads up (like use) a module at run time on demand
 Example :
 Returns :
 Args    :

=cut

sub _load_format_module {
    my ($self, $format) = @_;
    my $module = "Bio::SeqIO::" . $format;
    my $ok;

    eval {
        $ok = $self->_load_module($module);
    };
    if ( $@ ) {
        print STDERR <<END;
$self: $format cannot be found
Exception $@
For more information about the SeqIO system please see the SeqIO docs.
This includes ways of checking for formats at compile time, not run time
END
        ;
    }
    return $ok;
}


=head2 _concatenate_lines

 Title   : _concatenate_lines
 Usage   : $s = _concatenate_lines($line, $continuation_line)
 Function: Private. Concatenates two strings assuming that the second stems
           from a continuation line of the first. Adds a space between both
           unless the first ends with a dash.

           Takes care of either arg being empty.
 Example :
 Returns : A string.
 Args    :

=cut

sub _concatenate_lines {
    my ($self, $s1, $s2) = @_;
    $s1 .= " " if($s1 && ($s1 !~ /-$/) && $s2);
    return ($s1 ? $s1 : "") . ($s2 ? $s2 : "");
}


=head2 _filehandle

 Title   : _filehandle
 Usage   : $obj->_filehandle($newval)
 Function: This method is deprecated. Call _fh() instead.
 Example :
 Returns : value of _filehandle
 Args    : newvalue (optional)

=cut

sub _filehandle {
    my ($self,@args) = @_;
    return $self->_fh(@args);
}


=head2 _guess_format

 Title   : _guess_format
 Usage   : $obj->_guess_format($filename)
 Function: guess format based on file suffix
 Example :
 Returns : guessed format of filename (lower case)
 Args    :
 Notes   : formats that _filehandle() will guess include fasta,
           genbank, scf, pir, embl, raw, gcg, ace, bsml, swissprot,
           fastq and phd/phred

=cut

sub _guess_format {
   my $class = shift;
   return unless $_ = shift;

   return 'abi'        if /\.ab[i1]$/i;
   return 'ace'        if /\.ace$/i;
   return 'alf'        if /\.alf$/i;
   return 'bsml'       if /\.(bsm|bsml)$/i;
   return 'ctf'        if /\.ctf$/i;
   return 'embl'       if /\.(embl|ebl|emb|dat)$/i;
   return 'entrezgene' if /\.asn$/i;
   return 'exp'        if /\.exp$/i;
   return 'fasta'      if /\.(fasta|fast|fas|seq|fa|fsa|nt|aa|fna|faa)$/i;
   return 'fastq'      if /\.fastq$/i;
   return 'gcg'        if /\.gcg$/i;
   return 'genbank'    if /\.(gb|gbank|genbank|gbk|gbs)$/i;
   return 'phd'        if /\.(phd|phred)$/i;
   return 'pir'        if /\.pir$/i;
   return 'pln'        if /\.pln$/i;
   return 'qual'       if /\.qual$/i;
   return 'raw'        if /\.txt$/i;
   return 'scf'        if /\.scf$/i;
   # from Strider 1.4 Release Notes: The file name extensions used by
   # Strider 1.4 are ".xdna", ".xdgn", ".xrna" and ".xprt" for DNA,
   # DNA Degenerate, RNA and Protein Sequence Files, respectively
   return 'strider'    if /\.(xdna|xdgn|xrna|xprt)$/i;
   return 'swiss'      if /\.(swiss|sp)$/i;
   return 'ztr'        if /\.ztr$/i;
}


sub DESTROY {
    my $self = shift;
    $self->close();
}


sub TIEHANDLE {
    my ($class,$val) = @_;
    return bless {'seqio' => $val}, $class;
}


sub READLINE {
    my $self = shift;
    return $self->{'seqio'}->next_seq() || undef unless wantarray;
    my (@list, $obj);
    push @list, $obj while $obj = $self->{'seqio'}->next_seq();
    return @list;
}


sub PRINT {
    my $self = shift;
    $self->{'seqio'}->write_seq(@_);
}


=head2 sequence_factory

 Title   : sequence_factory
 Usage   : $seqio->sequence_factory($seqfactory)
 Function: Get/Set the Bio::Factory::SequenceFactoryI
 Returns : Bio::Factory::SequenceFactoryI
 Args    : [optional] Bio::Factory::SequenceFactoryI

=cut

sub sequence_factory {
   my ($self, $obj) = @_;
   if( defined $obj ) {
        if( ! ref($obj) || ! $obj->isa('Bio::Factory::SequenceFactoryI') ) {
            $self->throw("Must provide a valid Bio::Factory::SequenceFactoryI object to ".ref($self)."::sequence_factory()");
        }
        $self->{'_seqio_seqfactory'} = $obj;
        my $builder = $self->sequence_builder();
        if($builder && $builder->can('sequence_factory') &&
            (! $builder->sequence_factory())) {
            $builder->sequence_factory($obj);
        }
   }
   $self->{'_seqio_seqfactory'};
}


=head2 object_factory

 Title   : object_factory
 Usage   : $obj->object_factory($newval)
 Function: This is an alias to sequence_factory with a more generic name.
 Example :
 Returns : value of object_factory (a scalar)
 Args    : on set, new value (a scalar or undef, optional)

=cut

sub object_factory{
    return shift->sequence_factory(@_);
}


=head2 sequence_builder

 Title   : sequence_builder
 Usage   : $seqio->sequence_builder($seqfactory)
 Function: Get/Set the Bio::Factory::ObjectBuilderI used to build sequence
           objects. This applies to rich sequence formats only, e.g. genbank
           but not fasta.

           If you do not set the sequence object builder yourself, it
           will in fact be an instance of L<Bio::Seq::SeqBuilder>, and
           you may use all methods documented there to configure it.

 Returns : a Bio::Factory::ObjectBuilderI compliant object
 Args    : [optional] a Bio::Factory::ObjectBuilderI compliant object

=cut

sub sequence_builder {
    my ($self, $obj) = @_;
    if( defined $obj ) {
        if( ! ref($obj) || ! $obj->isa('Bio::Factory::ObjectBuilderI') ) {
            $self->throw("Must provide a valid Bio::Factory::ObjectBuilderI object to ".ref($self)."::sequence_builder()");
        }
        $self->{'_object_builder'} = $obj;
    }
    $self->{'_object_builder'};
}


=head2 location_factory

 Title   : location_factory
 Usage   : $seqio->location_factory($locfactory)
 Function: Get/Set the Bio::Factory::LocationFactoryI object to be used for
           location string parsing
 Returns : a Bio::Factory::LocationFactoryI implementing object
 Args    : [optional] on set, a Bio::Factory::LocationFactoryI implementing
           object.

=cut

sub location_factory {
    my ($self,$obj) = @_;
    if( defined $obj ) {
        if( ! ref($obj) || ! $obj->isa('Bio::Factory::LocationFactoryI') ) {
            $self->throw("Must provide a valid Bio::Factory::LocationFactoryI" .
                             " object to ".ref($self)."->location_factory()");
        }
        $self->{'_seqio_locfactory'} = $obj;
    }
    $self->{'_seqio_locfactory'};
}

1;

