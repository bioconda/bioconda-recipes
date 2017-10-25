# BioPerl module for Bio::SeqIO::tinyseq
#
# Please direct questions and support issues to <bioperl-l@bioperl.org>
#
# Cared for by Donald Jackson, donald.jackson@bms.com
#
# Copyright Bristol-Myers Squibb
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::tinyseq - reading/writing sequences in NCBI TinySeq format

=head1 SYNOPSIS

Do not use this module directly; use the SeqIO handler system:

  $stream = Bio::SeqIO->new( -file => $filename, -format => 'tinyseq' );

  while ( my $seq = $stream->next_seq ) {
    ....
  }

=head1 DESCRIPTION

This object reads and writes Bio::Seq objects to and from TinySeq XML
format.  A TinySeq is a lightweight XML file of sequence information,
analgous to FASTA format.

See L<http://www.ncbi.nlm.nih.gov/dtd/NCBI_TSeq.mod.dtd> for the DTD.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

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
of the bugs and their resolution. Bug reports can be submitted via
the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 SEE ALSO

L<Bio::SeqIO>, L<Bio::Seq>.

=head1 AUTHOR

Donald Jackson, E<lt>donald.jackson@bms.comE<gt>

Parts of this module and the test script were patterned after Sheldon
McKay's L<Bio::SeqIO::game>.  If it breaks, however, it's my fault not
his ;).

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

package Bio::SeqIO::tinyseq;

use strict;
use Bio::Seq::SeqFastaSpeedFactory;
use Bio::Species;
use Bio::SeqIO::tinyseq::tinyseqHandler;
use XML::Parser::PerlSAX;
use XML::Writer;
use Bio::Root::Version;

use base qw(Bio::SeqIO);

sub _initialize {
    my ($self, @args) = @_;

    $self->SUPER::_initialize(@args);

    unless (defined $self->sequence_factory) {
        $self->sequence_factory(Bio::Seq::SeqFastaSpeedFactory->new);
    }

    $self->{'_species_objects'} = {};
    $self->{_parsed} = 0;
}

=head2 next_seq

  Title   : next_seq
  Usage   : $seq = $stream->next_seq()
  Function: returns the next sequence in the stream
  Returns : Bio::Seq object
  Args    : NONE

=cut

sub next_seq {
    my ($self) = @_;

    $self->_get_seqs() unless ($self->{_parsed});

    return shift @{$self->{_seqlist}};
}

=head2 write_seq

  Title   : write_seq
  Usage   : $seq = $stream->write_seq(@sequence_objects); undef $stream
  Function: outputs one or more sequence objects as TinySeq XML
  Returns : 1 on success
  Args    : one or more sequence objects as TinySeq XML

Because the TSeq dtd includes closing tags after all sets are written,
the output will not be complete until the program terminates or the
object is forced out of scope (see close_writer()).  May not perfectly
reproduce TSeq_sid element for all sequences

=cut

sub write_seq {
    my ($self, @seqobjs) = @_;

    $self->throw('write_seq must be called with at least one  Bio::SeqI or Bio::PrimarySeqI compliant object')
        unless (@seqobjs and ( $seqobjs[0]->isa('Bio::SeqI') || $seqobjs[0]->isa('Bio::PrimarySeqI')));

    my $writer = $self->_get_writer;

    foreach my $seqobj (@seqobjs) {
        my ($id_element, $id_value) = $self->_get_idstring($seqobj);
        $writer->startTag('TSeq');
        $writer->emptyTag('TSeq_seqtype', value => $self->_convert_seqtype($seqobj));

        $writer->dataElement('TSeq_gi',       $seqobj->primary_id || '');
        $writer->dataElement($id_element,     $id_value);
        #$writer->dataElement('TSeq_orgname',  $seqobj->taxid) if ($seqobj->can('taxid')); # just a placeholder
        $writer->dataElement('TSeq_defline',  $seqobj->desc);
        $writer->dataElement('TSeq_length',   $seqobj->length);
        $writer->dataElement('TSeq_sequence', $seqobj->seq);

        if ($seqobj->can('species') && $seqobj->species) {
            $self->_write_species($writer, $seqobj->species);
        }

        $writer->endTag('TSeq');
    }
    1;
}

=head2 _get_seqs

  Title   : _get_seqs
  Usage   : Internal function - use next_seq() instead
  Function: parses the XML and creates Bio::Seq objects
  Returns : 1 on success
  Args    : NONE

Currently stores all sequence objects into memory.  I will work on do
more of a stream-based approach

=cut

sub _get_seqs {
    my ($self) = @_;
    my $fh = $self->_fh;

    my $handler = Bio::SeqIO::tinyseq::tinyseqHandler->new();
    my $parser  = XML::Parser::PerlSAX->new( Handler => $handler );
    my @seqatts = $parser->parse( Source => { ByteStream => $fh });
    my $factory = $self->sequence_factory;

    $self->{_seqlist} ||= [];
    foreach my $seqatt(@seqatts) {
        foreach my $subatt(@$seqatt) { # why are there two hashes?
            my $seqobj = $factory->create(%$subatt);
            $self->_assign_identifier($seqobj, $subatt);

            if ($seqobj->can('species')) {
#               my $class = [reverse(split(/ /, $subatt->{'-organism'}))];
#               my $species = Bio::Species->new( -classification => $class,
#                                                -ncbi_taxid     => $subatt->{'-taxid'} );
                my $species = $self->_get_species($subatt->{'-organism'}, $subatt->{'-taxid'});
                $seqobj->species($species) if ($species);
            }

            push(@{$self->{_seqlist}}, $seqobj);
        }
    }
    $self->{_parsed} = 1;
}

=head2 _get_species

  Title   : _get_species
  Usage   : Internal function
  Function: gets a Bio::Species object from cache or creates as needed
  Returns : a Bio::Species object on success, undef on failure
  Args    : a classification string (eg 'Homo sapiens') and
            a NCBI taxon id (optional)

Objects are cached for parsing multiple sequence files.

=cut

sub _get_species {
     my ($self, $orgname, $taxid) = @_;

     unless ($self->{'_species_objects'}->{$orgname}) {
         my $species = $self->_create_species($orgname, $taxid);
         $self->{'_species_objects'}->{$orgname} = $species;
     }
     return $self->{'_species_objects'}->{$orgname};
}

=head2 _create_species

  Title   : _create_species
  Usage   : Internal function
  Function: creates a Bio::Species object
  Returns : a Bio::Species object on success, undef on failure
  Args    : a classification string (eg 'Homo sapiens') and
                  a NCBI taxon id (optional)

=cut

sub _create_species {
    my ($self, $orgname, $taxid) = @_;
    return unless ($orgname); # not required in TinySeq dtd so don't throw an error

    my %params;
    $params{'-classification'} = [reverse(split(/ /, $orgname))];
    $params{'-ncbi_taxid'} = $taxid if ($taxid);

    my $species = Bio::Species->new(%params)
        or return;

    return $species;
}


=head2 _assign_identifier

  Title   : _assign_identifier
  Usage   : Internal function
  Function: looks for sequence accession
  Returns : 1 on success
  Args    : NONE

NCBI puts refseq accessions in TSeq_sid, others in TSeq_accver.

=cut

sub _assign_identifier {
    my ($self, $seqobj, $atts) = @_;
    my ($accession, $version);

   if ($atts->{'-accver'}) {
        ($accession, $version) = split(/\./, $atts->{'-accver'});;
    }
    elsif ($atts->{'-sid'}) {
        my $sidstring =$atts->{'-sid'};
        $sidstring =~ s/^.+?\|//;
        $sidstring =~ s/\|[^\|]*//;
        ($accession, $version) = split(/\./, $sidstring);;
    }
    else {
        $self->throw('NO accession information found for this sequence');
    }
    $seqobj->accession_number($accession) if ($seqobj->can('accession_number'));
    $seqobj->version($version) if ($seqobj->can('version'));
}

=head2 _convert_seqtype

  Title   : _convert_seqtype
  Usage   : Internal function
  Function: maps Bio::Seq::alphabet() values [dna/rna/protein] onto
            TSeq_seqtype values [protein/nucleotide]

=cut

sub _convert_seqtype {
    my ($self, $seqobj) = @_;

    return 'protein'    if ($seqobj->alphabet eq 'protein');
    return 'nucleotide' if ($seqobj->alphabet eq 'dna');
    return 'nucleotide' if ($seqobj->alphabet eq 'rna');

    # if we get here there's a problem!
    $self->throw("Alphabet not defined, can't assign type for $seqobj");
}

=head2 _get_idstring

  Title   : _get_idstring
  Usage   : Internal function
  Function: parse accession and version info from TSeq_accver
            or TSeq_sid

=cut

sub _get_idstring {
    # NCBI puts refseq ids in TSeq_sid, others in TSeq_accver.  No idea why.
    my ($self, $seqobj) = @_;
    my $accver = $seqobj->accession_number;
    $accver .= '.' . $seqobj->version if ($seqobj->can('version') and $seqobj->version);
    if ($accver =~ /^(NM_|NP_|XM_|XP_|NT_|NC_|NG_)/) {
        return ('TSeq_sid', join('|', 'ref', $accver, ''));
    }
    else {
        return ('TSeq_accver', $accver);
    }
}

=head2 _get_writer

  Title   : _get_writer
  Usage   : Internal function
  Function: instantiate XML::Writer object if needed,
                  output initial XML

=cut

sub _get_writer {
    # initialize writer, start doc so write_seq can work one at a time
    my ($self) = @_;

    unless ($self->{_writer}) {
        my $fh = $self->_fh;
        my $writer = XML::Writer->new(OUTPUT      => $fh,
                                      DATA_MODE   => 1,
                                      DATA_INDENT => 2,
                                      NEWLINE     => 1,
                                      );
        $writer->doctype('TSeqSet', '-//NCBI//NCBI TSeq/EN', 'http://www.ncbi.nlm.nih.gov/dtd/NCBI_TSeq.dtd');
        $writer->comment("Generated by Bio::SeqIO::tinyseq VERSION " . $Bio::Root::Version::VERSION);
        $writer->startTag('TSeqSet');

        $self->{_writer} = $writer;
    }
    return $self->{_writer};
}

=head2 close_writer

  Title   : close_writer
  Usage   : $self->close_writer()
  Function: terminate XML output
  Args    : NONE
  Returns : 1 on success

Called automatically by DESTROY when object goes out of scope

=cut

sub close_writer {
    # close out any dangling writer
    my ($self) = @_;
    if ($self->{_writer}) {
        my $writer = $self->{_writer};
        $writer->endTag('TSeqSet');
        $writer->end;
        undef $writer;
    }
    close($self->_fh) if ($self->_fh);
    1;
}

sub _write_species {
    my ($self, $writer, $species) = @_;
    $writer->dataElement('TSeq_orgname', $species->binomial);
    $writer->dataElement('TSeq_taxid',   $species->ncbi_taxid)
        if($species->ncbi_taxid);
}

sub DESTROY {
    # primarily to close out a writer!
    my ($self) = @_;
    $self->close_writer;
    undef $self;
}

1;
__END__
