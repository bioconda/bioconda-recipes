#
# BioPerl module for Bio::SeqIO::genbank
#
# Please direct questions and support issues to <bioperl-l@bioperl.org>
#
# Cared for by Bioperl project bioperl-l(at)bioperl.org
#
# Copyright Elia Stupka and contributors see AUTHORS section
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::genbank - GenBank sequence input/output stream

=head1 SYNOPSIS

It is probably best not to use this object directly, but
rather go through the SeqIO handler:

    $stream = Bio::SeqIO->new(-file   => $filename,
                              -format => 'GenBank');

    while ( my $seq = $stream->next_seq ) {
        # do something with $seq
    }


=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from GenBank flat
file databases.

There is some flexibility here about how to write GenBank output
that is not fully documented.

=head2 Optional functions

=over 3

=item _show_dna()

(output only) shows the dna or not

=item _post_sort()

(output only) provides a sorting func which is applied to the FTHelpers
before printing

=item _id_generation_func()

This is function which is called as

   print "ID   ", $func($seq), "\n";

To generate the ID line. If it is not there, it generates a sensible ID
line using a number of tools.

If you want to output annotations in Genbank format they need to be
stored in a Bio::Annotation::Collection object which is accessible
through the Bio::SeqI interface method L<annotation()|annotation>.

The following are the names of the keys which are pulled from a
L<Bio::Annotation::Collection> object:

 reference       - Should contain Bio::Annotation::Reference objects
 comment         - Should contain Bio::Annotation::Comment objects
 dblink          - Should contain a Bio::Annotation::DBLink object
 segment         - Should contain a Bio::Annotation::SimpleValue object
 origin          - Should contain a Bio::Annotation::SimpleValue object
 wgs             - Should contain a Bio::Annotation::SimpleValue object

=back

=head1 Where does the data go?

Data parsed in Bio::SeqIO::genbank is stored in a variety of data
fields in the sequence object that is returned. Here is a partial list
of fields.

Items listed as RichSeq or Seq or PrimarySeq and then NAME() tell you
the top level object which defines a function called NAME() which
stores this information.

Items listed as Annotation 'NAME' tell you the data is stored the
associated Bio::AnnotationCollectionI object which is associated with
Bio::Seq objects.  If it is explicitly requested that no annotations
should be stored when parsing a record of course they will not be
available when you try and get them.  If you are having this problem
look at the type of SeqBuilder that is being used to contruct your
sequence object.

 Comments             Annotation 'comment'
 References           Annotation 'reference'
 Segment              Annotation 'segment'
 Origin               Annotation 'origin'
 Dbsource             Annotation 'dblink'

 Accessions           PrimarySeq accession_number()
 Secondary accessions RichSeq get_secondary_accessions()
 GI number            PrimarySeq primary_id()
 LOCUS                PrimarySeq display_id()
 Keywords             RichSeq get_keywords()
 Dates                RichSeq get_dates()
 Molecule             RichSeq molecule()
 Seq Version          RichSeq seq_version()
 PID                  RichSeq pid()
 Division             RichSeq division()
 Features             Seq get_SeqFeatures()
 Alphabet             PrimarySeq alphabet()
 Definition           PrimarySeq description() or desc()
 Version              PrimarySeq version()

 Sequence             PrimarySeq seq()

There is more information in the Feature-Annotation HOWTO about each
field and how it is mapped to the Sequence object
L<http://bioperl.open-bio.org/wiki/HOWTO:Feature-Annotation>.

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
Chris Fields, cjfields at bioperl dot org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::genbank;
use strict;

use Bio::SeqIO::FTHelper;
use Bio::SeqFeature::Generic;
use Bio::Species;
use Bio::Seq::SeqFactory;
use Bio::Annotation::Collection;
use Bio::Annotation::Comment;
use Bio::Annotation::Reference;
use Bio::Annotation::DBLink;

use base qw(Bio::SeqIO);

# Note that a qualifier that exceeds one line (i.e. a long label) will
# automatically be quoted regardless:

our $FTQUAL_LINE_LENGTH = 60;

our %FTQUAL_NO_QUOTE = map {$_ => 1} qw(
    anticodon           citation
    codon               codon_start
    cons_splice         direction
    evidence            label
    mod_base            number
    rpt_type            rpt_unit
    transl_except       transl_table
    usedin
    );

our %DBSOURCE = map {$_ => 1} qw(
    EchoBASE     IntAct    SWISS-2DPAGE    ECO2DBASE    ECOGENE    TIGRFAMs
    TIGR    GO    InterPro    Pfam    PROSITE    SGD    GermOnline
    HSSP    PhosSite    Ensembl    RGD    AGD    ArrayExpress    KEGG
    H-InvDB    HGNC    LinkHub    PANTHER    PRINTS    SMART    SMR
    MGI    MIM    RZPD-ProtExp    ProDom    MEROPS    TRANSFAC    Reactome
    UniGene    GlycoSuiteDB    PIRSF    HSC-2DPAGE    PHCI-2DPAGE
    PMMA-2DPAGE    Siena-2DPAGE    Rat-heart-2DPAGE    Aarhus/Ghent-2DPAGE
    Biocyc    MetaCyc    Biocyc:Metacyc    GenomeReviews    FlyBase
    TMHOBP    COMPLUYEAST-2DPAGE    OGP    DictyBase    HAMAP
    PhotoList    Gramene    WormBase    WormPep    Genew    ZFIN
    PeroxiBase    MaizeDB    TAIR    DrugBank    REBASE    HPA
    swissprot    GenBank    GenPept    REFSEQ    embl    PDB    UniProtKB
    DIP    PeptideAtlas    PRIDE    CYGD    HOGENOME    Gene3D
    Project);

our %VALID_MOLTYPE = map {$_ => 1} qw(NA DNA RNA tRNA rRNA cDNA cRNA ms-DNA
    mRNA  uRNA  ss-RNA  ss-DNA  snRNA snoRNA PRT);

our %VALID_ALPHABET = (
    'bp' => 'dna',
    'aa' => 'protein',
    'rc' => '' # rc = release candidate; file has no sequences
);

sub _initialize {
    my($self, @args) = @_;

    $self->SUPER::_initialize(@args);
    # hash for functions for decoding keys.
    $self->{'_func_ftunit_hash'} = {};
    $self->_show_dna(1); # sets this to one by default. People can change it
    if ( not defined $self->sequence_factory ) {
        $self->sequence_factory
            (Bio::Seq::SeqFactory->new(-verbose => $self->verbose,
                                       -type    => 'Bio::Seq::RichSeq'));
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
    my ($self, @args) = @_;
    my %args    = @args;
    my $builder = $self->sequence_builder;
    my $seq;
    my %params;

  RECORDSTART:
    while (1) {
        my $buffer;
        my ( @acc,        @features );
        my ( $display_id, $annotation );
        my $species;

        # initialize; we may come here because of starting over
        @features   = ();
        $annotation = undef;
        @acc        = ();
        $species    = undef;
        %params     = ( -verbose => $self->verbose );    # reset hash
        local ($/) = "\n";
        while ( defined( $buffer = $self->_readline ) ) {
            last if index( $buffer, 'LOCUS       ' ) == 0;
        }
        return unless defined $buffer;                   # end of file
        $buffer =~ /^LOCUS\s+(\S.*)$/o
            or $self->throw(  "GenBank stream with bad LOCUS line. "
                            . "Not GenBank in my book. Got '$buffer'");
        my @tokens = split( ' ', $1 );

        # this is important to have the id for display in e.g. FTHelper,
        # otherwise you won't know which entry caused an error
        $display_id = shift @tokens;
        $params{'-display_id'} = $display_id;

        # may still be useful if we don't want the seq
        my $seqlength = shift @tokens;
        if ( exists $VALID_ALPHABET{$seqlength} ) {
            # moved one token too far.  No locus name?
            $self->warn(  "Bad LOCUS name?  Changing [$params{'-display_id'}] "
                        . "to 'unknown' and length to '$display_id'"
            );
            $params{'-display_id'} = 'unknown';
            $params{'-length'}     = $display_id;

            # add token back...
            unshift @tokens, $seqlength;
        }
        else {
            $params{'-length'} = $seqlength;
        }

        # the alphabet of the entry
        # shouldn't assign alphabet unless one
        # is specifically designated (such as for rc files)
        my $alphabet = lc( shift @tokens );
        $params{'-alphabet'} =
          ( exists $VALID_ALPHABET{$alphabet} )
          ? $VALID_ALPHABET{$alphabet}
          : $self->warn("Unknown alphabet: $alphabet");

        # for aa there is usually no 'molecule' (mRNA etc)
        if ( $params{'-alphabet'} eq 'protein' ) {
            $params{'-molecule'} = 'PRT';
        }
        else {
            $params{'-molecule'} = shift(@tokens);
        }

        # take care of lower case issues
        if ( $params{'-molecule'} eq 'dna' or $params{'-molecule'} eq 'rna' ) {
            $params{'-molecule'} = uc $params{'-molecule'};
        }
        $self->debug( "Unrecognized molecule type: " . $params{'-molecule'} )
            if not exists( $VALID_MOLTYPE{ $params{'-molecule'} } );

        my $circ = shift @tokens;
        if ( $circ eq 'circular' ) {
            $params{'-is_circular'} = 1;
            $params{'-division'}    = shift @tokens;
        }
        else {
            # 'linear' or 'circular' may actually be omitted altogether
            $params{'-division'} =
                ( CORE::length($circ) == 3 ) ? $circ : shift @tokens;
        }
        my $date = join( ' ', @tokens );    # we lump together the rest

        # this is per request bug #1513
        # we can handle:
        # 9-10-2003
        # 9-10-03
        # 09-10-2003
        # 09-10-03
        if ( $date =~ s/\s*((\d{1,2})-(\w{3})-(\d{2,4})).*/$1/ ) {
            if ( length($date) < 11 ) {
                # improperly formatted date
                # But we'll be nice and fix it for them
                my ( $d, $m, $y ) = ( $2, $3, $4 );
                if ( length($d) == 1 ) {
                    $d = "0$d";
                }

                # guess the century here
                if ( length($y) == 2 ) {
                    if ( $y > 60 ) {    # arbitrarily guess that '60' means 1960
                        $y = "19$y";
                    }
                    else {
                        $y = "20$y";
                    }
                    $self->warn(  "Date was malformed, guessing the "
                                . "century for $date to be $y\n"
                    );
                }
                $params{'-dates'} = [ join( '-', $d, $m, $y ) ];
            }
            else {
                $params{'-dates'} = [$date];
            }
        }

        # set them all at once
        $builder->add_slot_value(%params);
        %params = ();

        # parse the rest if desired, otherwise start over
        if ( not $builder->want_object ) {
            $builder->make_object;
            next RECORDSTART;
        }

        # set up annotation depending on what the builder wants
        if ( $builder->want_slot('annotation') ) {
            $annotation = Bio::Annotation::Collection->new;
        }

        $buffer = $self->_readline;
        while ( defined( my $line = $buffer ) ) {
            # Description line(s)
            if ($line =~ /^DEFINITION\s+(\S.*\S)/) {
                my @desc = ($1);
                while ( defined( $line = $self->_readline ) ) {
                    if ($line =~ /^\s+(.*)/) {
                        push( @desc, $1 );
                        next;
                    }
                    last;
                }
                $builder->add_slot_value( -desc => join( ' ', @desc ) );

                # we'll continue right here because DEFINITION
                # always comes at the top of the entry
                $buffer = $line;
            }

            # accession number (there can be multiple accessions)
            if ($line =~ /^ACCESSION\s+(\S.*\S)/) {
                push( @acc, split( /\s+/, $1 ) );
                while ( defined( $line = $self->_readline ) ) {
                    if ($line =~ /^\s+(.*)/) {
                        push( @acc, split( /\s+/, $1 ) );
                        next;
                    }
                    last;
                }
                $buffer = $line;
                next;
            }

            # PID
            elsif ($line =~ /^PID\s+(\S+)/) {
                $params{'-pid'} = $1;
            }

            # Version number
            elsif ($line =~ /^VERSION\s+(\S.+)$/) {
                my ( $acc, $gi ) = split( ' ', $1 );
                if ( $acc =~ /^\w+\.(\d+)/ ) {
                    $params{'-version'}     = $1;
                    $params{'-seq_version'} = $1;
                }
                if ( $gi && ( index( $gi, "GI:" ) == 0 ) ) {
                    $params{'-primary_id'} = substr( $gi, 3 );
                }
            }

            # Keywords
            elsif ($line =~ /^KEYWORDS\s+(\S.*)/) {
                my @kw = split( /\s*\;\s*/, $1 );
                while ( defined( $line = $self->_readline ) ) {
                    chomp $line;
                    if ($line =~ /^\s+(.*)/) {
                        push( @kw, split( /\s*\;\s*/, $1 ) );
                        next;
                    }
                    last;
                }

                @kw && $kw[-1] =~ s/\.$//;
                $params{'-keywords'} = \@kw;
                $buffer = $line;
                next;
            }

            # Organism name and phylogenetic information
            elsif ($line =~ /^SOURCE\s+\S/) {
                if ( $builder->want_slot('species') ) {
                    $species = $self->_read_GenBank_Species( \$buffer );
                    $builder->add_slot_value( -species => $species );
                }
                else {
                    while ( defined( $buffer = $self->_readline ) ) {
                        last if substr( $buffer, 0, 1 ) ne ' ';
                    }
                }
                next;
            }

            # References
            elsif ($line =~ /^REFERENCE\s+\S/) {
                if ($annotation) {
                    my @refs = $self->_read_GenBank_References( \$buffer );
                    foreach my $ref (@refs) {
                        $annotation->add_Annotation( 'reference', $ref );
                    }
                }
                else {
                    while ( defined( $buffer = $self->_readline ) ) {
                        last if substr( $buffer, 0, 1 ) ne ' ';
                    }
                }
                next;
            }

            # Project
            elsif ($line =~ /^PROJECT\s+(\S.*)/) {
                if ($annotation) {
                    my $project =
                        Bio::Annotation::SimpleValue->new( -value => $1 );
                    $annotation->add_Annotation( 'project', $project );
                }
            }

            # Comments
            elsif ($line =~ /^COMMENT\s+(\S.*)/) {
                if ($annotation) {
                    my $comment = $1;
                    while ( defined( $line = $self->_readline ) ) {
                        last if ($line =~ /^\S/);
                        $comment .= $line;
                    }
                    $comment =~ s/\n/ /g;
                    $comment =~ s/  +/ /g;
                    $annotation->add_Annotation(
                        'comment',
                        Bio::Annotation::Comment->new(
                            -text    => $comment,
                            -tagname => 'comment'
                        )
                    );
                    $buffer = $line;
                }
                else {
                    while ( defined( $buffer = $self->_readline ) ) {
                        last if substr( $buffer, 0, 1 ) ne ' ';
                    }
                }
                next;
            }

            # Corresponding Genbank nucleotide id, Genpept only
            elsif ($line =~ /^DB(?:SOURCE|LINK)\s+(\S.+)/) {
                if ($annotation) {
                    my $dbsource = $1;
                    while ( defined( $line = $self->_readline ) ) {
                        last if ($line =~ /^\S/);
                        $dbsource .= $line;
                    }

                    # deal with UniProKB dbsources
                    if ( $dbsource =~
                        s/(UniProt(?:KB)?|swissprot):\s+locus\s+(\S+)\,.+\n//
                        ) {
                        $annotation->add_Annotation(
                            'dblink',
                            Bio::Annotation::DBLink->new(
                                -primary_id => $2,
                                -database   => $1,
                                -tagname    => 'dblink'
                            )
                        );
                        if ( $dbsource =~ s/\s+created:\s+([^\.]+)\.\n// ) {
                            $annotation->add_Annotation(
                                'swissprot_dates',
                                Bio::Annotation::SimpleValue->new(
                                    -tagname => 'date_created',
                                    -value   => $1
                                )
                            );
                        }
                        while ( $dbsource =~
                               s/\s+(sequence|annotation)\s+updated:\s+([^\.]+)\.\n//g
                            ) {
                            $annotation->add_Annotation(
                                'swissprot_dates',
                                Bio::Annotation::SimpleValue->new(
                                    -tagname => 'date_updated',
                                    -value   => $2
                                )
                            );
                        }
                        $dbsource =~ s/\n/ /g;
                        if ( $dbsource =~
                            s/\s+xrefs:\s+((?:\S+,\s+)+\S+)\s+xrefs/xrefs/
                            ) {
                            # will use $i to determine even or odd
                            # for swissprot the accessions are paired
                            my $i = 0;
                            for my $dbsrc ( split( /,\s+/, $1 ) ) {
                                if (   $dbsrc =~ /(\S+)\.(\d+)/
                                    or $dbsrc =~ /(\S+)/
                                    ) {
                                    my ( $id, $version ) = ( $1, $2 );
                                    $version = '' unless defined $version;
                                    my $db = ( $id =~ /^\d\S{3}/ ) ? 'PDB'
                                           : ( $i++ % 2 )          ? 'GenPept'
                                           : 'GenBank';

                                    $annotation->add_Annotation(
                                        'dblink',
                                        Bio::Annotation::DBLink->new(
                                            -primary_id => $id,
                                            -version    => $version,
                                            -database   => $db,
                                            -tagname    => 'dblink'
                                        )
                                    );
                                }
                            }
                        }
                        elsif ( $dbsource =~ s/\s+xrefs:\s+(.+)\s+xrefs/xrefs/i ) {
                            # download screwed up and ncbi didn't put acc in for gi numbers
                            my $i = 0;
                            for my $id ( split( /\,\s+/, $1 ) ) {
                                my ( $acc, $db );
                                if ( $id =~ /gi:\s+(\d+)/ ) {
                                    $acc = $1;
                                    $db = ( $i++ % 2 ) ? 'GenPept' : 'GenBank';
                                }
                                elsif ( $id =~ /pdb\s+accession\s+(\S+)/ ) {
                                    $acc = $1;
                                    $db  = 'PDB';
                                }
                                else {
                                    $acc = $id;
                                    $db  = '';
                                }
                                $annotation->add_Annotation(
                                    'dblink',
                                    Bio::Annotation::DBLink->new(
                                        -primary_id => $acc,
                                        -database   => $db,
                                        -tagname    => 'dblink'
                                    )
                                );
                            }
                        }
                        else {
                            $self->debug("Cannot match $dbsource\n");
                        }
                        if ( $dbsource =~ s/xrefs\s+
                                            \(non\-sequence\s+databases\):\s+
                                            ((?:\S+,\s+)+\S+)//x
                            ) {
                            for my $id ( split( /\,\s+/, $1 ) ) {
                                my $db;

                                # this is because GenBank dropped the spaces!!!
                                # I'm sure we're not going to get this right
                                ##if ( $id =~ s/^://i ) {
                                ##    $db = $1;
                                ##}
                                $db = substr( $id, 0, index( $id, ':' ) );
                                if ( not exists $DBSOURCE{$db} ) {
                                    $db = '';    # do we want 'GenBank' here?
                                }
                                $id = substr( $id, index( $id, ':' ) + 1 );
                                $annotation->add_Annotation(
                                    'dblink',
                                    Bio::Annotation::DBLink->new(
                                        -primary_id => $id,
                                        -database   => $db,
                                        -tagname    => 'dblink'
                                    )
                                );
                            }
                        }
                    }
                    else {
                        if ( $dbsource =~
                            /^(\S*?):?\s*accession\s+(\S+)\.(\d+)/
                            ) {
                            my ( $db, $id, $version ) = ( $1, $2, $3 );
                            $annotation->add_Annotation(
                                'dblink',
                                Bio::Annotation::DBLink->new(
                                    -primary_id => $id,
                                    -version    => $version,
                                    -database   => $db || 'GenBank',
                                    -tagname    => 'dblink'
                                )
                            );
                        }
                        elsif ( $dbsource =~ /^(\S*?):?\s*accession\s+(\S+)/ ) {
                            my ( $db, $id ) = ( $1, $2 );
                            $annotation->add_Annotation(
                                'dblink',
                                Bio::Annotation::DBLink->new(
                                    -primary_id => $id,
                                    -database   => $db || 'GenBank',
                                    -tagname    => 'dblink'
                                )
                            );
                        }
                        elsif ( $dbsource =~ /(\S+)([\.:])\s*(\S+)/ ) {
                            my ( $db, $version );
                            my @ids = ();
                            if ( $2 eq ':' ) {
                                $db = $1;

                                # Genbank 192 release notes say this: "The second
                                # field can consist of multiple comma-separated
                                # identifiers, if a sequence record has multiple
                                # DBLINK cross-references of a given type."
                                # For example: DBLINK      Project:100,200,300"
                                @ids = split( /,/, $3 );
                            }
                            else {
                                ( $db, $version ) = ( 'GenBank', $3 );
                                $ids[0] = $1;
                            }

                            foreach my $id (@ids) {
                                $annotation->add_Annotation(
                                    'dblink',
                                    Bio::Annotation::DBLink->new(
                                        -primary_id => $id,
                                        -version    => $version,
                                        -database   => $db,
                                        -tagname    => 'dblink'
                                    )
                                );
                            }
                        }
                        else {
                            $self->warn(
                                "Unrecognized DBSOURCE data: $dbsource\n");
                        }
                    }
                    $buffer = $line;
                }
                else {
                    while ( defined( $buffer = $self->_readline ) ) {
                        last if substr( $buffer, 0, 1 ) ne ' ';
                    }
                }
                next;
            }

            # Exit at start of Feature table, or start of sequence
            if ($line =~ /^(FEATURES|ORIGIN)/) {
                my $trap;
            }
            last if ($line =~ /^(FEATURES|ORIGIN)/);

            # Get next line and loop again
            $buffer = $self->_readline;
        }
        return unless defined $buffer;

        # add them all at once for efficiency
        $builder->add_slot_value(
            -accession_number     => shift(@acc),
            -secondary_accessions => \@acc,
            %params
        );
        $builder->add_slot_value( -annotation => $annotation ) if $annotation;
        %params = ();    # reset before possible re-use to avoid setting twice

        # start over if we don't want to continue with this entry
        if ( not $builder->want_object ) {
            $builder->make_object;
            next RECORDSTART;
        }

        # some "minimal" formats may not necessarily have a feature table
        if (    $builder->want_slot('features')
            and defined $buffer
            and $buffer =~ /^FEATURES/o
            ) {
            # need to read the first line of the feature table
            $buffer = $self->_readline;

            # DO NOT read lines in the while condition -- this is done
            # as a side effect in _read_FTHelper_GenBank!

            # part of new circular spec:
            # commented out for now until kinks worked out
            #my $sourceEnd = 0;
            #$sourceEnd = $2 if ($buffer =~ /(\d+?)\.\.(\d+?)$/);

            while ( defined $buffer ) {
                # check immediately -- not at the end of the loop
                # note: GenPept entries obviously do not have a BASE line
                last if ( $buffer =~ /^BASE|ORIGIN|CONTIG|WGS/o );

                # slurp in one feature at a time -- at return, the start of
                # the next feature will have been read already, so we need
                # to pass a reference, and the called method must set this
                # to the last line read before returning
                my $ftunit = $self->_read_FTHelper_GenBank( \$buffer );

                # implement new circular spec: features that cross the origin are now
                # seamless instead of being 2 separate joined features
                # commented out until kinks get worked out
                #if ((! $args{'-nojoin'}) && $ftunit->{'loc'} =~ /^join\((\d+?)\.\.(\d+?),(\d+?)..(\d+?)\)$/
                #&& $sourceEnd == $2 && $3 == 1) {
                #my $start = $1;
                #my $end = $2 + $4;
                #$ftunit->{'loc'} = "$start..$end";
                #}

                # fix suggested by James Diggans

                if ( not defined $ftunit ) {
                    # GRRRR. We have fallen over. Try to recover
                    $self->warn(  "Unexpected error in feature table for "
                                . $params{'-display_id'}
                                . " Skipping feature, attempting to recover" );

                    unless (   $buffer =~ /^\s{5,5}\S+/o
                            or $buffer =~ /^\S+/o
                        ) {
                        $buffer = $self->_readline;
                    }
                    next;    # back to reading FTHelpers
                }

                # process ftunit
                my $feat =
                    $ftunit->_generic_seqfeature( $self->location_factory,
                                                  $display_id );

                # add taxon_id from source if available
                if (   $species
                    and $feat->primary_tag eq 'source'
                    and $feat->has_tag('db_xref')
                    and (    not $species->ncbi_taxid
                         or (    $species->ncbi_taxid
                             and $species->ncbi_taxid =~ /^list/ ) )
                    ) {
                    foreach my $tagval ( $feat->get_tag_values('db_xref') ) {
                        if ( index( $tagval, "taxon:" ) == 0 ) {
                            $species->ncbi_taxid( substr( $tagval, 6 ) );
                            last;
                        }
                    }
                }

                # add feature to list of features
                push( @features, $feat );
            }
            $builder->add_slot_value( -features => \@features );
        }

        if ( defined $buffer ) {
            # CONTIG lines: TODO, this needs to be cleaned up
            if ($buffer =~/^CONTIG\s+(.*)/o) {
                my $ctg = $1;
                while ( defined( $buffer = $self->_readline ) ) {
                    last if $buffer =~ m{^ORIGIN|//}o;
                    $buffer =~ s/\s+(.*)/$1/;
                    $ctg .= $buffer;
                }
                if ($ctg) {
                    $annotation->add_Annotation(
                        Bio::Annotation::SimpleValue->new(
                            -tagname => 'contig',
                            -value   => $ctg
                        )
                    );
                }
            }
            elsif ($buffer =~ /^WGS|WGS_SCAFLD\s+/o) {    # catch WGS/WGS_SCAFLD lines
                while ( $buffer =~ s/(^WGS|WGS_SCAFLD)\s+// ) {    # gulp lines
                    chomp $buffer;
                    $annotation->add_Annotation(
                        Bio::Annotation::SimpleValue->new(
                            -value   => $buffer,
                            -tagname => lc $1
                        )
                    );
                    $buffer = $self->_readline;
                }
            }
            elsif ( $buffer !~ m{^ORIGIN|//}o ) {    # advance to the sequence, if any
                while ( defined( $buffer = $self->_readline ) ) {
                    last if $buffer =~ m{^(ORIGIN|//)};
                }
            }
        }
        if ( not $builder->want_object ) {
            $builder->make_object;        # implicit end-of-object
            next RECORDSTART;
        }
        if ( $builder->want_slot('seq') ) {
            # the fact that we want a sequence does not necessarily mean that
            # there also is a sequence ...
            if ( defined $buffer and $buffer =~ s/^ORIGIN\s+// ) {
                if ( $annotation and length($buffer) > 0 ) {
                    $annotation->add_Annotation(
                        'origin',
                        Bio::Annotation::SimpleValue->new(
                            -tagname => 'origin',
                            -value   => $buffer
                        )
                    );
                }
                my $seqc = '';
                while ( defined( $buffer = $self->_readline ) ) {
                    last if $buffer =~ m{^//};
                    $buffer = uc $buffer;
                    $buffer =~ s/[^A-Za-z]//g;
                    $seqc .= $buffer;
                }

                $builder->add_slot_value( -seq => $seqc );
            }
        }
        elsif ( defined($buffer) and ( substr( $buffer, 0, 2 ) ne '//' ) ) {
            # advance to the end of the record
            while ( defined( $buffer = $self->_readline ) ) {
                last if substr( $buffer, 0, 2 ) eq '//';
            }
        }

        # Unlikely, but maybe the sequence is so weird that we don't want it
        # anymore. We don't want to return undef if the stream's not exhausted
        # yet.
        $seq = $builder->make_object;
        next RECORDSTART unless $seq;
        last RECORDSTART;
    }    # end while RECORDSTART

    return $seq;
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object (must be seq) to the stream
 Returns : 1 for success and 0 for error
 Args    : array of 1 to n Bio::SeqI objects

=cut

sub write_seq {
    my ($self,@seqs) = @_;

    foreach my $seq ( @seqs ) {
        $self->throw("Attempting to write with no seq!") unless defined $seq;

        if ( not ref $seq or not $seq->isa('Bio::SeqI') ) {
            $self->warn(" $seq is not a SeqI compliant module. Attempting to dump, but may fail!");
        }

        my $str   = $seq->seq;
        my $len   = $seq->length;
        my $alpha = $seq->alphabet;

        my ($div, $mol);
        if (   not $seq->can('division')
            or not defined($div = $seq->division)
            ) {
            $div = 'UNK';
        }
        if (   not $seq->can('molecule')
            or not defined ($mol = $seq->molecule)
           ) {
            $mol =  $alpha || 'DNA';
        }

        my $circular = ($seq->is_circular) ? 'circular' : 'linear  ';

        local($^W) = 0; # supressing warnings about uninitialized fields.

        my $temp_line;
        if ( $self->_id_generation_func ) {
            $temp_line = &{$self->_id_generation_func}($seq);
        }
        else {
            my $date = '';
            if ( $seq->can('get_dates') ) {
                ($date) = $seq->get_dates;
            }

            $self->warn("No whitespace allowed in GenBank display id [". $seq->display_id. "]")
                if $seq->display_id =~ /\s/;

            my @data = ( lc($alpha) eq 'protein' ) ? ('aa', '', '') : ('bp', '', $mol);
            $temp_line = sprintf ("%-12s%-15s%13s %s%4s%-8s%-8s %3s %-s\n",
                                  'LOCUS', $seq->id, $len,
                                  @data, $circular, $div, $date);
        }

        $self->_print($temp_line);
        $self->_write_line_GenBank_regex("DEFINITION  ", "            ",
                                         $seq->desc,     "\\s\+\|\$",80);

        # if there, write the accession line

        if ( $self->_ac_generation_func ) {
            $temp_line = &{$self->_ac_generation_func}($seq);
            $self->_print("ACCESSION   $temp_line\n");
        }
        else {
            my @acc = ();
            push @acc, $seq->accession_number;
            if ( $seq->isa('Bio::Seq::RichSeqI') ) {
                push @acc, $seq->get_secondary_accessions;
            }
            $self->_print("ACCESSION   ", join(" ", @acc), "\n");
            # otherwise - cannot print <sigh>
        }

        # if PID defined, print it
        if ($seq->isa('Bio::Seq::RichSeqI') and $seq->pid) {
            $self->_print("PID         ", $seq->pid, "\n");
        }

        # if there, write the version line
        if ( defined $self->_sv_generation_func ) {
            $temp_line = &{$self->_sv_generation_func}($seq);
            if ( $temp_line ) {
                $self->_print("VERSION     $temp_line\n");
            }
        }
        elsif ($seq->isa('Bio::Seq::RichSeqI') and defined($seq->seq_version)) {
            my $id = $seq->primary_id; # this may be a GI number
            my $data = (defined $id and $id =~ /^\d+$/) ? "  GI:$id" : "";
            $self->_print("VERSION     ",
                          $seq->accession_number, ".",
                          $seq->seq_version, $data, "\n");
        }

        # if there, write the PROJECT line
        for my $proj ( $seq->annotation->get_Annotations('project') ) {
            $self->_print("PROJECT     ".$proj->value."\n");
        }

        # if there, write the DBSOURCE line
        foreach my $ref ( $seq->annotation->get_Annotations('dblink') ) {
            my ($db, $id) = ($ref->database, $ref->primary_id);
            my $prefix = $db eq 'Project' ? 'DBLINK' : 'DBSOURCE';
            my $text   = $db eq 'GenBank' ? ''
                       : $db eq 'Project' ? "$db:$id"
                       : "$db accession $id";
            $self->_print(sprintf ("%-11s %s\n", $prefix, $text));
        }

        # if there, write the keywords line
        if ( defined $self->_kw_generation_func ) {
            $temp_line = &{$self->_kw_generation_func}($seq);
            $self->_print("KEYWORDS    $temp_line\n");
        }
        elsif ( $seq->can('keywords') ) {
            my $kw = $seq->keywords;
            $kw .= '.' if ( $kw !~ /\.$/ );
            $self->_print("KEYWORDS    $kw\n");
        }

        # SEGMENT if it exists
        foreach my $ref ( $seq->annotation->get_Annotations('segment') ) {
            $self->_print(sprintf ("%-11s %s\n",'SEGMENT',
                                   $ref->value));
        }

        # Organism lines
        if (my $spec = $seq->species) {
            my ($on, $sn, $cn) = ($spec->can('organelle') ? $spec->organelle : '',
                                  $spec->scientific_name,
                                  $spec->common_name);
            my @classification;
            if ($spec->isa('Bio::Species')) {
                @classification = $spec->classification;
                shift @classification;
            }
            else {
                # Bio::Taxon should have a DB handle of some type attached, so
                # derive the classification from that
                my $node = $spec;
                while ($node) {
                    $node = $node->ancestor || last;
                    unshift @classification, $node->node_name;
                    #$node eq $root && last;
                }
                @classification = reverse @classification;
            }
            my $abname = $spec->name('abbreviated') ? # from genbank file
                         $spec->name('abbreviated')->[0] : $sn;
            my $sl = $on ? "$on "          : '';
            $sl   .= $cn ? "$abname ($cn)" : $abname;

            $self->_write_line_GenBank_regex("SOURCE      ", ' 'x12, $sl, "\\s\+\|\$", 80);
            $self->_print("  ORGANISM  ", $spec->scientific_name, "\n");
            my $OC = join('; ', reverse @classification) . '.';
            $self->_write_line_GenBank_regex(' 'x12,' 'x12, $OC, "\\s\+\|\$", 80);
        }

        # Reference lines
        my $count = 1;
        foreach my $ref ( $seq->annotation->get_Annotations('reference') ) {
            $temp_line = "REFERENCE   $count";
            if ($ref->start) {
                $temp_line .= sprintf ("  (%s %d to %d)",
                                       ($seq->alphabet() eq "protein" ?
                                        "residues" : "bases"),
                                       $ref->start, $ref->end);
            }
            elsif ($ref->gb_reference) {
                $temp_line .= sprintf ("  (%s)", $ref->gb_reference);
            }
            $self->_print("$temp_line\n");
            $self->_write_line_GenBank_regex("  AUTHORS   ", ' 'x12,
                                             $ref->authors,    "\\s\+\|\$", 80);
            $self->_write_line_GenBank_regex("  CONSRTM   ", ' 'x12,
                                             $ref->consortium, "\\s\+\|\$", 80) if $ref->consortium;
            $self->_write_line_GenBank_regex("  TITLE     ", ' 'x12,
                                             $ref->title,      "\\s\+\|\$", 80);
            $self->_write_line_GenBank_regex("  JOURNAL   ", ' 'x12,
                                             $ref->location,   "\\s\+\|\$", 80);
            if ( $ref->medline) {
                $self->_write_line_GenBank_regex("  MEDLINE   ", ' 'x12,
                                                 $ref->medline,  "\\s\+\|\$", 80);
                # I am assuming that pubmed entries only exist when there
                # are also MEDLINE entries due to the indentation
            }
            # This could be a wrong assumption
            if ( $ref->pubmed ) {
                $self->_write_line_GenBank_regex("   PUBMED   ", ' 'x12,
                                                 $ref->pubmed,   "\\s\+\|\$", 80);
            }
            # put remark at the end
            if ($ref->comment) {
                $self->_write_line_GenBank_regex("  REMARK    ", ' 'x12,
                                                 $ref->comment,  "\\s\+\|\$", 80);
            }
            $count++;
        }

        # Comment lines
        foreach my $comment ( $seq->annotation->get_Annotations('comment') ) {
            $self->_write_line_GenBank_regex("COMMENT     ", ' 'x12,
                                             $comment->text, "\\s\+\|\$", 80);
        }

        # FEATURES section
        $self->_print("FEATURES             Location/Qualifiers\n");

        if ( defined $self->_post_sort ) {
            # we need to read things into an array. Process. Sort them. Print 'em
            my $post_sort_func = $self->_post_sort;
            my @fth;

            foreach my $sf ( $seq->top_SeqFeatures ) {
                push @fth, Bio::SeqIO::FTHelper::from_SeqFeature($sf, $seq);
            }

            @fth = sort { &$post_sort_func($a, $b) } @fth;

            foreach my $fth ( @fth ) {
                $self->_print_GenBank_FTHelper($fth);
            }
        }
        else {
            # not post sorted. And so we can print as we get them.
            # lower memory load...
            foreach my $sf ( $seq->top_SeqFeatures ) {
                my @fth = Bio::SeqIO::FTHelper::from_SeqFeature($sf, $seq);
                foreach my $fth ( @fth ) {
                    if ( ! $fth->isa('Bio::SeqIO::FTHelper') ) {
                        $sf->throw("Cannot process FTHelper... $fth");
                    }
                    $self->_print_GenBank_FTHelper($fth);
                }
            }
        }

        # deal with WGS; WGS_SCAFLD present only if WGS is also present
        if ($seq->annotation->get_Annotations('wgs')) {
            foreach my $wgs (map {$seq->annotation->get_Annotations($_)}
                             qw(wgs wgs_scaffold)
                ) {
                $self->_print(sprintf ("%-11s %s\n",
                                       uc($wgs->tagname),
                                       $wgs->value));
            }
            $self->_show_dna(0);
        }
        if ($seq->annotation->get_Annotations('contig')) {
            my $ct = 0;
            my $cline;
            foreach my $contig ($seq->annotation->get_Annotations('contig')) {
                unless ($ct) {
                    $cline = uc($contig->tagname) . "      " . $contig->value . "\n";
                }
                else {
                    $cline = "            " . $contig->value . "\n";
                }
                $self->_print($cline);
                $ct++;
            }
            $self->_show_dna(0);
        }
        if ( $seq->length == 0 ) {
            $self->_show_dna(0);
        }

        if ( $self->_show_dna == 0 ) {
            $self->_print("\n//\n");
            return;
        }

        # finished printing features.

        $str =~ tr/A-Z/a-z/;

        my ($o) = $seq->annotation->get_Annotations('origin');
        $self->_print(sprintf("%-12s%s\n",
                              'ORIGIN', $o ? $o->value : ''));
        # print out the sequence
        my $nuc = 60;           # Number of nucleotides per line
        my $whole_pat = 'a10' x 6; # Pattern for unpacking a whole line
        my $out_pat   = 'A11' x 6; # Pattern for packing a line
        my $length = length $str;

        # Calculate the number of nucleotides which fit on whole lines
        my $whole = int($length / $nuc) * $nuc;

        # Print the whole lines
        my $i;
        for ($i = 0; $i < $whole; $i += $nuc) {
            my $blocks = pack $out_pat,
            unpack $whole_pat,
            substr($str, $i, $nuc);
            chop $blocks;
            $self->_print(sprintf("%9d $blocks\n", $i + $nuc - 59));
        }

        # Print the last line
        if (my $last = substr($str, $i)) {
            my $last_len = length($last);
            my $last_pat = 'a10' x int($last_len / 10)
                         . 'a' . $last_len % 10;
            my $blocks = pack $out_pat,
            unpack($last_pat, $last);
            $blocks =~ s/ +$//;
            $self->_print(sprintf("%9d $blocks\n",
                                  $length - $last_len + 1));
        }

        $self->_print("//\n");

        $self->flush if $self->_flush_on_write && defined $self->_fh;
        return 1;
    }
}

=head2 _print_GenBank_FTHelper

 Title   : _print_GenBank_FTHelper
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

sub _print_GenBank_FTHelper {
    my ( $self, $fth ) = @_;

    if ( not ref $fth or not $fth->isa('Bio::SeqIO::FTHelper') ) {
        $fth->warn(
            "$fth is not a FTHelper class. Attempting to print but there could be issues"
        );
    }

    my $spacer = ( length $fth->key >= 15 ) ? ' ' : '';
    $self->_write_line_GenBank_regex(
        sprintf( "     %-16s%s", $fth->key, $spacer ),
                 " " x 21, $fth->loc, "\,\|\$", 80 );

    foreach my $tag ( keys %{ $fth->field } ) {
        # Account for hash structure in Annotation::DBLink, not the expected array
        if ( $tag eq 'db_xref' and grep /HASH/, @{ $fth->field->{$tag} }) {
            for my $ref ( @{ $fth->field->{$tag} } ) {
                my $db = $ref->{'database'};
                my $id = $ref->{'primary_id'};
                $self->_write_line_GenBank_regex
                    ( " " x 21, " " x 21,
                      "/$tag=\"$db:$id\"", "\.\|\$", 80 );
            }
        }
        # The usual case, where all values are found in an array
        else {
            foreach my $value ( @{ $fth->field->{$tag} } ) {
                $value =~ s/\"/\"\"/g;
                if ( $value eq "_no_value" ) {
                    $self->_write_line_GenBank_regex
                        ( " " x 21, " " x 21,
                          "/$tag", "\.\|\$", 80 );
                }

               # There are almost 3x more quoted qualifier values and they
               # are more common too so we take quoted ones first.
               # Long qualifiers, that will be line wrapped, are always quoted
                elsif (   not $FTQUAL_NO_QUOTE{$tag}
                       or length("/$tag=$value") >= $FTQUAL_LINE_LENGTH
                    ) {
                    my ($pat) = ( $value =~ /\s/ ? '\s|$' : '.|$' );
                    $self->_write_line_GenBank_regex
                        ( " " x 21, " " x 21,
                          "/$tag=\"$value\"", $pat, 80 );
                }
                else {
                    $self->_write_line_GenBank_regex
                        ( " " x 21, " " x 21,
                          "/$tag=$value", "\.\|\$", 80 );
                }
            }
        }
    }
}

=head2 _read_GenBank_References

 Title   : _read_GenBank_References
 Usage   :
 Function: Reads references from GenBank format. Internal function really
 Returns :
 Args    :

=cut

sub _read_GenBank_References {
    my ($self, $buffer) = @_;
    my (@refs);
    my $ref;

    # assumme things are starting with RN
    if ( $$buffer !~ /^REFERENCE/ ) {
        warn("Not parsing line '$$buffer' which maybe important");
    }

    my $line = $$buffer;

    my (@title,@loc,@authors,@consort,@com,@medline,@pubmed);

  REFLOOP:
    while( defined($line) or defined($line = $self->_readline) ) {
        if ($line =~ /^\s{2}AUTHORS\s+(.*)/o) {
            push @authors, $1;
            while ( defined($line = $self->_readline) ) {
                if ($line =~ /^\s{9,}(.*)/o) {
                    push @authors, $1;
                    next;
                }
                last;
            }
            $ref->authors(join(' ', @authors));
        }

        if ($line =~ /^\s{2}CONSRTM\s+(.*)/o) {
            push @consort, $1;
            while ( defined($line = $self->_readline) ) {
                if ($line =~ /^\s{9,}(.*)/o) {
                    push @consort, $1;
                    next;
                }
                last;
            }
            $ref->consortium(join(' ', @consort));
        }

        if ($line =~ /^\s{2}TITLE\s+(.*)/o) {
            push @title, $1;
            while ( defined($line = $self->_readline) ) {
                if ($line =~ /^\s{9,}(.*)/o) {
                    push @title, $1;
                    next;
                }
                last;
            }
            $ref->title(join(' ', @title));
        }

        if ($line =~ /^\s{2}JOURNAL\s+(.*)/o) {
            push @loc, $1;
            while ( defined($line = $self->_readline) ) {
                # we only match when there are at least 4 spaces
                # there is probably a better way to match this
                # as it assumes that the describing tag is short enough
                if ($line =~ /^\s{9,}(.*)/o) {
                    push @loc, $1;
                    next;
                }
                last;
            }
            $ref->location(join(' ', @loc));
            redo REFLOOP;
        }

        if ($line =~ /^\s{2}REMARK\s+(.*)/o) {
            push @com, $1;
            while ( defined($line = $self->_readline) ) {
                if ($line =~ /^\s{9,}(.*)/o) {
                    push @com, $1;
                    next;
                }
                last;
            }
            $ref->comment(join(' ', @com));
            redo REFLOOP;
        }

        if ( $line =~ /^\s{2}MEDLINE\s+(.*)/ ) {
            push @medline, $1;
            while ( defined($line = $self->_readline) ) {
                if ($line =~ /^\s{9,}(.*)/) {
                    push @medline, $1;
                    next;
                }
                last;
            }
            $ref->medline(join(' ', @medline));
            redo REFLOOP;
        }

        if ( $line =~ /^\s{3}PUBMED\s+(.*)/ ) {
            push @pubmed, $1;
            while ( defined($line = $self->_readline) ) {
                if ($line =~ /^\s{9,}(.*)/) {
                    push @pubmed, $1;
                    next;
                }
                last;
            }
            $ref->pubmed(join(' ', @pubmed));
            redo REFLOOP;
        }

        if ( $line =~ /^REFERENCE/o ) {
            # store current reference
            $self->_add_ref_to_array(\@refs,$ref) if defined $ref;

            # reset
            @authors = ();
            @title   = ();
            @loc     = ();
            @com     = ();
            @pubmed  = ();
            @medline = ();

            # create the new reference object
            $ref = Bio::Annotation::Reference->new(-tagname => 'reference');

            # check whether start and end base is given
            if ($line =~ /^REFERENCE\s+\d+\s+\([a-z]+ (\d+) to (\d+)\)/){
                $ref->start($1);
                $ref->end($2);
            }
            elsif ($line =~ /^REFERENCE\s+\d+\s+\((.*)\)/) {
                $ref->gb_reference($1);
            }
        }

        last if ($line =~ /^(FEATURES)|(COMMENT)/o);

        $line = undef; # Empty $line to trigger read of next line
    }

    # store last reference
    $self->_add_ref_to_array(\@refs, $ref) if defined $ref;

    $$buffer = $line;

    #print "\nnumber of references found: ", $#refs+1,"\n";

    return @refs;
}

=head2 _add_ref_to_array

Title: _add_ref_to_array
Usage:
Function: Adds a Reference object to an array of Reference objects, takes
          care of possible cleanups to be done (currently, only author and title
          will be chopped of trailing semicolons).
Args:     A reference to an array of Reference objects and
          the Reference object to be added
Returns: nothing

=cut

sub _add_ref_to_array {
    my ($self, $refs, $ref) = @_;

    # first, polish author and title by removing possible trailing semicolons
    my $au    = $ref->authors;
    my $title = $ref->title;
    $au    =~ s/;\s*$//g if $au;
    $title =~ s/;\s*$//g if $title;
    $ref->authors($au);
    $ref->title($title);
    # the rest should be clean already, so go ahead and add it
    push @{$refs}, $ref;
}

=head2 _read_GenBank_Species

 Title   : _read_GenBank_Species
 Usage   :
 Function: Reads the GenBank Organism species and classification
           lines. Able to deal with unconvential Organism naming
           formats, and varietas in plants
 Example : ORGANISM  unknown marine gamma proteobacterium NOR5
           $genus = undef
           $species = unknown marine gamma proteobacterium NOR5

           ORGANISM  Drosophila sp. 'white tip scutellum'
           $genus = Drosophila
           $species = sp. 'white tip scutellum'
           (yes, this really is a species and that is its name)
           $subspecies = undef

           ORGANISM  Ajellomyces capsulatus var. farciminosus
           $genus = Ajellomyces
           $species = capsulatus
           $subspecies = var. farciminosus

           ORGANISM  Hepatitis delta virus
           $genus = undef (though this virus has a genus in its lineage, we
                           cannot know that without a database lookup)
           $species = Hepatitis delta virus

 Returns : A Bio::Species object
 Args    : A reference to the current line buffer

=cut

sub _read_GenBank_Species {
    my ($self, $buffer) = @_;

    my @unkn_names = ('other', 'unknown organism', 'not specified', 'not shown',
                      'Unspecified', 'Unknown', 'None', 'unclassified',
                      'unidentified organism', 'not supplied');
    # dictionary of synonyms for taxid 32644
    my @unkn_genus = ('unknown', 'unclassified', 'uncultured', 'unidentified');
    # all above can be part of valid species name

    my $line = $$buffer;

    my( $sub_species, $species, $genus, $sci_name, $common,
        $class_lines, $source_flag, $abbr_name, $organelle, $sl );
    my %source = map { $_ => 1 } qw(SOURCE ORGANISM CLASSIFICATION);

    # upon first entering the loop, we must not read a new line -- the SOURCE
    # line is already in the buffer (HL 05/10/2000)
    my ($ann, $tag, $data);
    while (defined($line) or defined($line = $self->_readline)) {
        # de-HTMLify (links that may be encountered here don't contain
        # escaped '>', so a simple-minded approach suffices)
        $line =~ s{<[^>]+>}{}g;
        if ($line =~ m{^(?:\s{0,2})(\w+)\s+(.+)?$}ox) {
            ($tag, $data) = ($1, $2 || '');
            last if ($tag and not exists $source{$tag});
        }
        else {
            return unless $tag;
            ($data = $line) =~ s{^\s+}{};
            chomp $data;
            $tag = 'CLASSIFICATION' if (    $tag ne 'CLASSIFICATION'
                                        and $tag eq 'ORGANISM'
                                        # Don't match "str." or "var." (NC_021815)
                                        and  $line =~ m{(?<!\bstr|\bvar)[;\.]+});
        }
        (exists $ann->{$tag}) ? ($ann->{$tag} .= ' '.$data) : ($ann->{$tag} .= $data);
        $line = undef;
    }

    ($sl, $class_lines, $sci_name) = ($ann->{SOURCE}, $ann->{CLASSIFICATION}, $ann->{ORGANISM});

    $$buffer = $line;

    $sci_name or return;

    # parse out organelle, common name, abbreviated name if present;
    # this should catch everything, but falls back to
    # entire SOURCE line just in case
    if ($sl =~ m{^(mitochondrion|chloroplast|plastid)?
                  \s*(.*?)
                  \s*(?: \( (.*?) \) )?\.?
                  $
                 }xms
        ) {
        ($organelle, $abbr_name, $common) = ($1, $2, $3); # optional
    }
    else {
        $abbr_name = $sl; # nothing caught; this is a backup!
    }

    # Convert data in classification lines into classification array.
    # only split on ';' or '.' so that classification that is 2 or more words will
    # still get matched, use map() to remove trailing/leading/intervening spaces
    my @class = map { $_ =~ s/^\s+//;
                      $_ =~ s/\s+$//;
                      $_ =~ s/\s{2,}/ /g;
                      $_; }
                split /(?<!subgen)[;\.]+/, $class_lines;

    # do we have a genus?
    my $possible_genus =  quotemeta($class[-1])
                       . ($class[-2] ? "|" . quotemeta($class[-2]) : '');
    if ($sci_name =~ /^($possible_genus)/) {
        $genus = $1;
        ($species) = $sci_name =~ /^$genus\s+(.+)/;
    }
    else {
        $species = $sci_name;
    }

    # is this organism of rank species or is it lower?
    # (we don't catch everything lower than species, but it doesn't matter -
    # this is just so we abide by previous behaviour whilst not calling a
    # species a subspecies)
    if ($species and $species =~ /(.+)\s+((?:subsp\.|var\.).+)/) {
        ($species, $sub_species) = ($1, $2);
    }

    # Don't make a species object if it's empty or "Unknown" or "None"
    # return unless $genus and  $genus !~ /^(Unknown|None)$/oi;
    # Don't make a species object if it belongs to taxid 32644
#    my $unkn = grep { $_ =~ /^\Q$sl\E$/; } @unkn_names;
    my $unkn = grep { $_ eq $sl } @unkn_names;
    return unless (defined $species or defined $genus) and $unkn == 0;

    # Bio::Species array needs array in Species -> Kingdom direction
    push @class, $sci_name;
    @class = reverse @class;

    my $make = Bio::Species->new;
    $make->scientific_name($sci_name);
    $make->classification(@class)          if @class > 0;
    $make->common_name( $common )          if $common;
    $make->name('abbreviated', $abbr_name) if $abbr_name;
    $make->organelle($organelle)           if $organelle;
    #$make->sub_species( $sub_species )     if $sub_species;
    return $make;
}

=head2 _read_FTHelper_GenBank

 Title   : _read_FTHelper_GenBank
 Usage   : _read_FTHelper_GenBank($buffer)
 Function: reads the next FT key line
 Example :
 Returns : Bio::SeqIO::FTHelper object
 Args    : filehandle and reference to a scalar

=cut

sub _read_FTHelper_GenBank {
    my ($self, $buffer) = @_;

    my ($key, # The key of the feature
        $loc  # The location line from the feature
    );
    my @qual = (); # An array of lines making up the qualifiers

    if ($$buffer =~ /^\s{5}(\S+)\s+(.+?)\s*$/o) {
        $key = $1;
        $loc = $2;
        # Read all the lines up to the next feature
        while ( defined(my $line = $self->_readline) ) {
            if ($line =~ /^(\s+)(.+?)\s*$/o) {
                # Lines inside features are preceded by 21 spaces
                # A new feature is preceded by 5 spaces
                if (length($1) > 6) {
                    # Add to qualifiers if we're in the qualifiers, or if it's
                    # the first qualifier
                    if (@qual or (index($2,'/') == 0)) {
                        push @qual, $2;
                    }
                    # We're still in the location line, so append to location
                    else {
                        $loc .= $2;
                    }
                }
                else {
                    # We've reached the start of the next feature
                    # Put the first line of the next feature into the buffer
                    $$buffer = $line;
                    last;
                }
            }
            else {
                # We're at the end of the feature table
                # Put the first line of the next feature into the buffer
                $$buffer = $line;
                last;
            }
        }
    }
    else {
        # No feature key
        $self->debug("no feature key!\n");
        # change suggested by JDiggans to avoid infinite loop-
        # see bugreport 1062.
        # reset buffer to prevent infinite loop
        $$buffer = $self->_readline;
        return;
    }

    # Make the new FTHelper object
    my $out = Bio::SeqIO::FTHelper->new;
    $out->verbose($self->verbose);
    $out->key($key);
    $out->loc($loc);

    # Now parse and add any qualifiers.  (@qual is kept
    # intact to provide informative error messages.)
  QUAL:
    for (my $i = 0; $i < @qual; $i++) {
        my $data = $qual[$i];
        my ( $qualifier, $value ) = ($data =~ m{^/([^=]+)(?:=(.+))?})
            or $self->warn(  "cannot see new qualifier in feature $key: "
                           . $qual[$i]);
        $qualifier = '' unless( defined $qualifier );

        if (defined $value) {
            # Do we have a quoted value?
            if (substr($value, 0, 1) eq '"') {
                # Keep adding to value until we find the trailing quote
                # and the quotes are balanced
                while ($value !~ /\"$/ or $value =~ tr/"/"/ % 2) {
                    if ($i >= $#qual) {
                        $self->warn(  "Unbalanced quote in:\n"
                                    . join("\n", @qual)
                                    . "No further qualifiers will "
                                    . "be added for this feature");
                        last QUAL;
                    }
                    # modifying a for-loop variable inside of the loop
                    # is not the best programming style ...
                    $i++;
                    my $next = $qual[$i];

                    # add to value with a space unless the value appears
                    # to be a sequence (translation for example)
                    # if (($value.$next) =~ /[^A-Za-z\"\-]/o) {
                    # changed to explicitly look for translation tag - cjf 06/8/29
                    if ($qualifier !~ /^translation$/i ) {
                        $value .= " ";
                    }
                    $value .= $next;
                }
                # Trim leading and trailing quotes
                $value =~ s/^"|"$//g;
                # Undouble internal quotes
                $value =~ s/""/\"/g;
            }
            elsif ( $value =~ /^\(/ ) { # values quoted by ()s
                # Keep adding to value until we find the trailing bracket
                # and the ()s are balanced
                my $left  = ($value =~ tr/\(/\(/); # count left parens
                my $right = ($value =~ tr/\)/\)/); # count right parens

                while( $left != $right ) { # was "$value !~ /\)$/ or $left != $right"
                    if ( $i >= $#qual) {
                        $self->warn(  "Unbalanced parens in:\n"
                                    . join("\n", @qual)
                                    . "\nNo further qualifiers will "
                                    . "be added for this feature");
                        last QUAL;
                    }
                    $i++;
                    my $next = $qual[$i];
                    $value .=  $next;
                    $left  += ($next =~ tr/\(/\(/);
                    $right += ($next =~ tr/\)/\)/);
                }
            }
        }
        else {
            $value = '_no_value';
        }
        # Store the qualifier
        $out->field->{$qualifier} ||= [];
        push @{$out->field->{$qualifier}}, $value;
    }
    return $out;
}

=head2 _write_line_GenBank

 Title   : _write_line_GenBank
 Usage   :
 Function: internal function
 Example :
 Returns :
 Args    :

=cut

sub _write_line_GenBank {
    my ($self, $pre1, $pre2, $line, $length) = @_;

    $length or $self->throw("Miscalled write_line_GenBank without length. Programming error!");
    my $subl  = $length - length $pre2;
    my $linel = length $line;
    my $i;

    my $subr = substr($line,0,$length - length $pre1);

    $self->_print("$pre1$subr\n");
    for($i = ($length - length $pre1); $i < $linel; $i += $subl) {
        $subr = substr($line, $i, $subl);
        $self->_print("$pre2$subr\n");
    }
}

=head2 _write_line_GenBank_regex

 Title   : _write_line_GenBank_regex
 Usage   :
 Function: internal function for writing lines of specified
           length, with different first and the next line
           left hand headers and split at specific points in the
           text
 Example :
 Returns : nothing
 Args    : file handle,
           first header,
           second header,
           text-line,
           regex for line breaks,
           total line length

=cut

sub _write_line_GenBank_regex {
    my ($self, $pre1, $pre2, $line, $regex, $length) = @_;

    #print STDOUT "Going to print with $line!\n";

    $length or $self->throw("Miscalled write_line_GenBank without length. Programming error!");

    my $subl  = $length - (length $pre1) - 2;
    my @lines = ();

  CHUNK:
    while ($line) {
        foreach my $pat ($regex, '[,;\.\/-]\s|'.$regex, '[,;\.\/-]|'.$regex) {
            if ($line =~ m/^(.{0,$subl})($pat)(.*)/ ) {
                my $l = $1 . $2;
                $line = substr($line, length $l);
                # be strict about not padding spaces according to
                # genbank format
                $l =~ s/\s+$//;
                next CHUNK if ($l eq '');
                push @lines, $l;
                next CHUNK;
            }
        }
        # if we get here none of the patterns matched $subl or less chars
        $self->warn(  "trouble dissecting \"$line\"\n     into chunks "
                    . "of $subl chars or less - this tag won't print right");
        # insert a space char to prevent infinite loops
        $line = substr($line, 0, $subl) . " " . substr($line, $subl);
    }
    my $s = shift @lines;
    $self->_print("$pre1$s\n") if $s;
    foreach my $s ( @lines ) {
        $self->_print("$pre2$s\n");
    }
}

=head2 _post_sort

 Title   : _post_sort
 Usage   : $obj->_post_sort($newval)
 Function:
 Returns : value of _post_sort
 Args    : newvalue (optional)

=cut

sub _post_sort {
    my ($obj,$value) = @_;
    if ( defined $value) {
        $obj->{'_post_sort'} = $value;
    }
    return $obj->{'_post_sort'};
}

=head2 _show_dna

 Title   : _show_dna
 Usage   : $obj->_show_dna($newval)
 Function:
 Returns : value of _show_dna
 Args    : newvalue (optional)

=cut

sub _show_dna {
    my ($obj,$value) = @_;
    if ( defined $value) {
        $obj->{'_show_dna'} = $value;
    }
    return $obj->{'_show_dna'};
}

=head2 _id_generation_func

 Title   : _id_generation_func
 Usage   : $obj->_id_generation_func($newval)
 Function:
 Returns : value of _id_generation_func
 Args    : newvalue (optional)

=cut

sub _id_generation_func {
    my ($obj,$value) = @_;
    if ( defined $value ) {
        $obj->{'_id_generation_func'} = $value;
    }
    return $obj->{'_id_generation_func'};
}

=head2 _ac_generation_func

 Title   : _ac_generation_func
 Usage   : $obj->_ac_generation_func($newval)
 Function:
 Returns : value of _ac_generation_func
 Args    : newvalue (optional)

=cut

sub _ac_generation_func {
    my ($obj,$value) = @_;
    if ( defined $value ) {
        $obj->{'_ac_generation_func'} = $value;
    }
    return $obj->{'_ac_generation_func'};
}

=head2 _sv_generation_func

 Title   : _sv_generation_func
 Usage   : $obj->_sv_generation_func($newval)
 Function:
 Returns : value of _sv_generation_func
 Args    : newvalue (optional)

=cut

sub _sv_generation_func {
    my ($obj,$value) = @_;
    if ( defined $value ) {
        $obj->{'_sv_generation_func'} = $value;
    }
    return $obj->{'_sv_generation_func'};
}

=head2 _kw_generation_func

 Title   : _kw_generation_func
 Usage   : $obj->_kw_generation_func($newval)
 Function:
 Returns : value of _kw_generation_func
 Args    : newvalue (optional)

=cut

sub _kw_generation_func {
    my ($obj,$value) = @_;
    if ( defined $value ) {
        $obj->{'_kw_generation_func'} = $value;
    }
    return $obj->{'_kw_generation_func'};
}

1;
