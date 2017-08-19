#
# BioPerl module for Bio::SeqIO::EMBL
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::embl - EMBL sequence input/output stream

=head1 SYNOPSIS

It is probably best not to use this object directly, but
rather go through the SeqIO handler system. Go:

    $stream = Bio::SeqIO->new(-file => $filename, -format => 'EMBL');

    while ( (my $seq = $stream->next_seq()) ) {
        # do something with $seq
    }

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from EMBL flat
file databases.

There is a lot of flexibility here about how to dump things which
should be documented more fully.

There should be a common object that this and Genbank share (probably
with Swissprot). Too much of the magic is identical.

=head2 Optional functions

=over 3

=item _show_dna()

(output only) shows the dna or not

=item _post_sort()

(output only) provides a sorting func which is applied to the FTHelpers
before printing

=item _id_generation_func()

This is function which is called as

   print "ID   ", $func($annseq), "\n";

To generate the ID line. If it is not there, it generates a sensible ID
line using a number of tools.

If you want to output annotations in EMBL format they need to be
stored in a Bio::Annotation::Collection object which is accessible
through the Bio::SeqI interface method L<annotation()|annotation>.

The following are the names of the keys which are polled from a
L<Bio::Annotation::Collection> object.

 reference  - Should contain Bio::Annotation::Reference objects
 comment    - Should contain Bio::Annotation::Comment objects
 dblink     - Should contain Bio::Annotation::DBLink objects

=back

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
the bugs and their resolution. Bug reports can be submitted via
the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SeqIO::embl;
use vars qw(%FTQUAL_NO_QUOTE);
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
%FTQUAL_NO_QUOTE=(
                  'anticodon'=>1,
                  'citation'=>1,
                  'codon'=>1,
                  'codon_start'=>1,
                  'cons_splice'=>1,
                  'direction'=>1,
                  'evidence'=>1,
                  'label'=>1,
                  'mod_base'=> 1,
                  'number'=> 1,
                  'rpt_type'=> 1,
                  'rpt_unit'=> 1,
                  'transl_except'=> 1,
                  'transl_table'=> 1,
                  'usedin'=> 1,
                 );

sub _initialize {
    my($self,@args) = @_;

    $self->SUPER::_initialize(@args);
    # hash for functions for decoding keys.
    $self->{'_func_ftunit_hash'} = {};
    # sets this to one by default. People can change it
    $self->_show_dna(1);
    if ( ! defined $self->sequence_factory ) {
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

sub next_seq {
    my ($self,@args) = @_;
    my ($pseq,$c,$line,$name,$desc,$acc,$seqc,$mol,$div,
        $date, $comment, @date_arr);

    my ($annotation, %params, @features) =
        Bio::Annotation::Collection->new();

    $line = $self->_readline;
    # This needs to be before the first eof() test

    if ( !defined $line ) {
        return;                 # no throws - end of file
    }

    if ( $line =~ /^\s+$/ ) {
        while ( defined ($line = $self->_readline) ) {
            $line =~/^\S/ && last;
        }
        # return without error if the whole next sequence was just a single
        # blank line and then eof
        return unless $line;
    }

    # no ID as 1st non-blank line, need short circuit and exit routine
    $self->throw("EMBL stream with no ID. Not embl in my book")
        unless $line =~ /^ID\s+\S+/;

    # At this point we are sure that $line contains an ID header line
    my $alphabet;
    if ( $line =~ tr/;/;/ == 6) { # New style headers contain exactly six semicolons.

        # New style header (EMBL Release >= 87, after June 2006)
        my $topology;
        my $sv;

        # ID   DQ299383; SV 1; linear; mRNA; STD; MAM; 431 BP.
        # This regexp comes from the new2old.pl conversion script, from EBI
        if ($line =~ m/^ID   (\S+);\s+SV (\d+); (\w+); ([^;]+); (\w{3}); (\w{3}); (\d+) BP./) {
            ($name, $sv, $topology, $mol, $div) = ($1, $2, $3, $4, $6);
        }
        if (defined $sv) {
            $params{'-seq_version'} = $sv;
            $params{'-version'} = $sv;
        }

        if (defined $topology && $topology eq 'circular') {
            $params{'-is_circular'} = 1;
        }
    
        if (defined $mol ) {
            if ($mol =~ /DNA/) {
                $alphabet = 'dna';
            } elsif ($mol =~ /RNA/) {
                $alphabet = 'rna';
            } elsif ($mol =~ /AA/) {
                $alphabet = 'protein';
            }
        }
    } else {
    
        # Old style header (EMBL Release < 87, before June 2006)
        if ($line =~ /^ID\s+(\S+)[^;]*;\s+(\S+)[^;]*;\s+(\S+)[^;]*;/) {
        ($name, $mol, $div) = ($1, $2, $3);
        }
    
        if ($mol) {
            if ( $mol =~ /circular/ ) {
            $params{'-is_circular'} = 1;
            $mol =~  s|circular ||;
            }
            if (defined $mol ) {
            if ($mol =~ /DNA/) {
                $alphabet='dna';
            } elsif ($mol =~ /RNA/) {
                $alphabet='rna';
            } elsif ($mol =~ /AA/) {
                $alphabet='protein';
            }
            }
        }
    }

    unless( defined $name && length($name) ) {
    $name = "unknown_id";
    }

    # $self->warn("not parsing upper annotation in EMBL file yet!");
    my $buffer = $line;
    local $_;
    BEFORE_FEATURE_TABLE :
          my $ncbi_taxid;
          until ( !defined $buffer ) {
              $_ = $buffer;
              # Exit at start of Feature table
              if ( /^(F[HT]|SQ)/ ) {
                  $self->_pushback($_) if( $1 eq 'SQ' || $1 eq 'FT');
                  last;
              }
              # Description line(s)
              if (/^DE\s+(\S.*\S)/) {
                  $desc .= $desc ? " $1" : $1;
              }

              #accession number
              if ( /^AC\s+(.*)?/ || /^PA\s+(.*)?/) {
                  my @accs = split(/[; ]+/, $1); # allow space in addition
                  $params{'-accession_number'} = shift @accs
                      unless defined $params{'-accession_number'};
                  push @{$params{'-secondary_accessions'}}, @accs;
              }

              #version number
              if ( /^SV\s+\S+\.(\d+);?/ ) {
                  my $sv = $1;
                  #$sv =~ s/\;//;
                  $params{'-seq_version'} = $sv;
                  $params{'-version'} = $sv;
              }

              #date (NOTE: takes last date line)
              if ( /^DT\s+(.+)$/ ) {
                  my $line = $1;
                  my ($date, $version) = split(' ', $line, 2);
                  $date =~ tr/,//d; # remove comma if new version
                  if ($version) {
                  if ($version =~ /\(Rel\. (\d+), Created\)/xms ) {
                      my $release = Bio::Annotation::SimpleValue->new(
                                                                      -tagname    => 'creation_release',
                                                                      -value      => $1
                                                                     );
                      $annotation->add_Annotation($release);
                  } elsif ($version =~ /\(Rel\. (\d+), Last updated, Version (\d+)\)/xms ) {
                      my $release = Bio::Annotation::SimpleValue->new(
                                                                      -tagname    => 'update_release',
                                                                      -value      => $1
                                                                     );
                      $annotation->add_Annotation($release);

                      my $update = Bio::Annotation::SimpleValue->new(
                                                                     -tagname    => 'update_version',
                                                                     -value      => $2
                                                                    );
                      $annotation->add_Annotation($update);
                  }
                  }
                  push @{$params{'-dates'}}, $date;
              }

              #keywords
              if ( /^KW   (.*)\S*$/ ) {
                  my @kw = split(/\s*\;\s*/,$1);
                  push @{$params{'-keywords'}}, @kw;
              }

              # Organism name and phylogenetic information
              elsif (/^O[SC]/) {
                  # pass the accession number so we can give an informative throw message if necessary
                  my $species = $self->_read_EMBL_Species(\$buffer, $params{'-accession_number'});
                  $params{'-species'}= $species;
              }

              # NCBI TaxID Xref
              elsif (/^OX/) {
                  if (/NCBI_TaxID=(\d+)/) {
                      $ncbi_taxid=$1;
                  }

                  my @links = $self->_read_EMBL_TaxID_DBLink(\$buffer);
                  foreach my $dblink ( @links ) {
                      $annotation->add_Annotation('dblink',$dblink);
                  }
              }

              # References
              elsif (/^R/) {
                  my @refs = $self->_read_EMBL_References(\$buffer);
                  foreach my $ref ( @refs ) {
                      $annotation->add_Annotation('reference',$ref);
                  }
              }

              # DB Xrefs
              elsif (/^DR/) {
                  my @links = $self->_read_EMBL_DBLink(\$buffer);
                  foreach my $dblink ( @links ) {
                      $annotation->add_Annotation('dblink',$dblink);
                  }
              }

              # Comments
              elsif (/^CC\s+(.*)/) {
                  $comment .= $1;
                  $comment .= " ";
                  while (defined ($_ = $self->_readline) ) {
                      if (/^CC\s+(.*)/) {
                          $comment .= $1;
                          $comment .= " ";
                      } else {
                          last;
                      }
                  }
                  my $commobj = Bio::Annotation::Comment->new();
                  $commobj->text($comment);
                  $annotation->add_Annotation('comment',$commobj);
                  $comment = "";
              }

              # Get next line.
              $buffer = $self->_readline;
          }

    while ( defined ($_ = $self->_readline) ) {
        /^FT\s{3}\w/ && last;
        /^SQ / && last;
        /^CO / && last;
    }
    $buffer = $_;

    if (defined($buffer) && $buffer =~ /^FT /) {
        until ( !defined ($buffer) ) {
            my $ftunit = $self->_read_FTHelper_EMBL(\$buffer);

            # process ftunit
            my $feat =
                $ftunit->_generic_seqfeature($self->location_factory(), $name);

            # add taxon_id from source if available
            # Notice, this will override what is found in the OX line.
            # this is by design as this seems to be the official way
            # of specifying a TaxID
            if ($params{'-species'} && ($feat->primary_tag eq 'source')
                && $feat->has_tag('db_xref')
                && (! $params{'-species'}->ncbi_taxid())) {
                foreach my $tagval ($feat->get_tag_values('db_xref')) {
                    if (index($tagval,"taxon:") == 0) {
                        $params{'-species'}->ncbi_taxid(substr($tagval,6));
                        last;
                    }
                }
            }

            # add feature to list of features
            push(@features, $feat);

            if ( $buffer !~ /^FT/ ) {
                last;
            }
        }
    }
    # Set taxid found in OX line
    if ($params{'-species'} && defined $ncbi_taxid
        && (! $params{'-species'}->ncbi_taxid())) {
        $params{'-species'}->ncbi_taxid($ncbi_taxid);
    }

    # skip comments
    while ( defined ($buffer) && $buffer =~ /^XX/ ) {
        $buffer = $self->_readline();
    }
    
    if ( $buffer =~ /^CO/  ) {
	# bug#2982
	# special : create contig as annotation
        while ( defined ($buffer) ) {
	    $annotation->add_Annotation($_) for $self->_read_EMBL_Contig(\$buffer);
            if ( !$buffer || $buffer !~ /^CO/ ) {
                last;
	    }
        }
        $buffer ||= '';
    }
    if ($buffer !~ /^\/\//) { # if no SQ lines following CO (bug#2958)
    if ( $buffer !~ /^SQ/ ) {
        while ( defined ($_ = $self->_readline) ) {
            /^SQ/ && last;
        }
    }
    $seqc = "";
    while ( defined ($_ = $self->_readline) ) {
        m{^//} && last;
        $_ = uc($_);
        s/[^A-Za-z]//g;
        $seqc .= $_;
    }
}
    my $seq = $self->sequence_factory->create
        (-verbose => $self->verbose(),
         -division => $div,
         -seq => $seqc,
         -desc => $desc,
         -display_id => $name,
         -annotation => $annotation,
         -molecule => $mol,
         -alphabet => $alphabet,
         -features => \@features,
         %params);
    return $seq;
}



=head2 _write_ID_line

 Title   : _write_ID_line
 Usage   : $self->_write_ID_line($seq);
 Function: Writes the EMBL Release 87 format ID line to the stream, unless
         : there is a user-supplied ID line generation function in which
         : case that is used instead.
         : ( See Bio::SeqIO::embl::_id_generation_function(). )
 Returns : nothing
 Args    : Bio::Seq object

=cut

sub _write_ID_line {

    my ($self, $seq) = @_;

    my $id_line;
    # If there is a user-supplied ID generation function, use it.
    if ( $self->_id_generation_func ) {
        $id_line = "ID   " . &{$self->_id_generation_func}($seq) . "\nXX\n";
    }
    # Otherwise, generate a standard EMBL release 87 (June 2006) ID line.
    else {

        # The sequence name is supposed to be the primary accession number,
        my $name = $seq->accession_number();
        if ( not(defined $name) || $name eq 'unknown') {
            # but if it is not present, use the sequence ID or the empty string
            $name = $seq->id() || '';
        }
 
        $self->warn("No whitespace allowed in EMBL id [". $name. "]") if $name =~ /\s/;

        # Use the sequence version, or default to 1.
        my $version = $seq->version() || 1;

        my $len = $seq->length();

        # Taxonomic division.
        my $div;
        if ( $seq->can('division') && defined($seq->division) &&
             $self->_is_valid_division($seq->division) ) {
            $div = $seq->division();
        } else {
            $div ||= 'UNC';     # 'UNC' is the EMBL division code for 'unclassified'.
        }

        my $mol;
        # If the molecule type is a valid EMBL type, use it.
        if (  $seq->can('molecule')
              && defined($seq->molecule)
              && $self->_is_valid_molecule_type($seq->molecule)
           ) {
            $mol = $seq->molecule();
        }
        # Otherwise, choose unassigned DNA or RNA based on the alphabet.
        elsif ($seq->can('primary_seq') && defined $seq->primary_seq->alphabet) {
            my $alphabet =$seq->primary_seq->alphabet;
            if ($alphabet eq 'dna') {
                $mol ='unassigned DNA';
            } elsif ($alphabet eq 'rna') {
                $mol='unassigned RNA';
            } elsif ($alphabet eq 'protein') {
                $self->warn("Protein sequence found; EMBL is a nucleotide format.");
                $mol='AA';  # AA is not a valid EMBL molecule type.
            }
        }

        my $topology = 'linear';
        if ($seq->is_circular) {
            $topology = 'circular';
        }

        $mol ||= '';            # 'unassigned'; ?
        $id_line = "ID   $name; SV $version; $topology; $mol; STD; $div; $len BP.\nXX\n";
        $self->_print($id_line);
    }
}

=head2 _is_valid_division

 Title   : _is_valid_division
 Usage   : $self->_is_valid_division($div)
 Function: tests division code for validity
 Returns : true if $div is a valid EMBL release 87 taxonomic division.
 Args    : taxonomic division code string

=cut

sub _is_valid_division {
    my ($self, $division) = @_;

    my %EMBL_divisions = (
                          "PHG"    => 1, # Bacteriophage
                          "ENV"    => 1, # Environmental Sample
                          "FUN"    => 1, # Fungal
                          "HUM"    => 1, # Human
                          "INV"    => 1, # Invertebrate
                          "MAM"    => 1, # Other Mammal
                          "VRT"    => 1, # Other Vertebrate
                          "MUS"    => 1, # Mus musculus
                          "PLN"    => 1, # Plant
                          "PRO"    => 1, # Prokaryote
                          "ROD"    => 1, # Other Rodent
                          "SYN"    => 1, # Synthetic
                          "UNC"    => 1, # Unclassified
                          "VRL"    => 1 # Viral
                         );

    return exists($EMBL_divisions{$division});
}

=head2 _is_valid_molecule_type

 Title   : _is_valid_molecule_type
 Usage   : $self->_is_valid_molecule_type($mol)
 Function: tests molecule type for validity
 Returns : true if $mol is a valid EMBL release 87 molecule type.
 Args    : molecule type string

=cut

sub _is_valid_molecule_type {
    my ($self, $moltype) = @_;

    my %EMBL_molecule_types = (
                               "genomic DNA"    => 1,
                               "genomic RNA"    => 1,
                               "mRNA"           => 1,
                               "tRNA"           => 1,
                               "rRNA"           => 1,
                               "snoRNA"         => 1,
                               "snRNA"          => 1,
                               "scRNA"          => 1,
                               "pre-RNA"        => 1,
                               "other RNA"      => 1,
                               "other DNA"      => 1,
                               "unassigned DNA" => 1,
                               "unassigned RNA" => 1
                              );

    return exists($EMBL_molecule_types{$moltype});
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object (must be seq) to the stream
 Returns : 1 for success and undef for error
 Args    : array of 1 to n Bio::SeqI objects


=cut

sub write_seq {
    my ($self,@seqs) = @_;

    foreach my $seq ( @seqs ) {
        $self->throw("Attempting to write with no seq!") unless defined $seq;
        unless ( ref $seq && $seq->isa('Bio::SeqI' ) ) {
            $self->warn("$seq is not a SeqI compliant sequence object!")
                if $self->verbose >= 0;
            unless ( ref $seq && $seq->isa('Bio::PrimarySeqI' ) ) {
                $self->throw("$seq is not a PrimarySeqI compliant sequence object!");
            }
        }
        my $str = $seq->seq || '';

        # Write the ID line.
        $self->_write_ID_line($seq);


        # Write the accession line if present
        my( $acc );
        {
            if ( my $func = $self->_ac_generation_func ) {
                $acc = &{$func}($seq);
            } elsif ( $seq->isa('Bio::Seq::RichSeqI') &&
                      defined($seq->accession_number) ) {
                $acc = $seq->accession_number;
                $acc = join("; ", $acc, $seq->get_secondary_accessions);
            } elsif ( $seq->can('accession_number') ) {
                $acc = $seq->accession_number;
            }

            if (defined $acc) {
                $self->_print("AC   $acc;\n",
                              "XX\n") || return;
            }
        }

        # Date lines
        my $switch=0;
        if ( $seq->can('get_dates') ) {
            my @dates =  $seq->get_dates();
            my $ct = 1;
            my $date_flag = 0;
            my ($cr) = $seq->annotation->get_Annotations("creation_release");
            my ($ur) = $seq->annotation->get_Annotations("update_release");
            my ($uv) = $seq->annotation->get_Annotations("update_version");

            unless ($cr && $ur && $ur) {
                $date_flag = 1;
            }

            foreach my $dt (@dates) {
                if (!$date_flag) {
                    $self->_write_line_EMBL_regex("DT   ","DT   ",
                                                  $dt." (Rel. $cr, Created)",
                                                  '\s+|$',80) if $ct == 1;
                    $self->_write_line_EMBL_regex("DT   ","DT   ",
                                                  $dt." (Rel. $ur, Last updated, Version $uv)",
                                                  '\s+|$',80) if $ct == 2;
                } else {        # other formats?
                    $self->_write_line_EMBL_regex("DT   ","DT   ",
                                                  $dt,'\s+|$',80);
                }
                $switch =1;
                $ct++;
            }
            if ($switch == 1) {
                $self->_print("XX\n") || return;
            }
        }

        # Description lines
        $self->_write_line_EMBL_regex("DE   ","DE   ",$seq->desc(),'\s+|$',80) || return; #'
        $self->_print( "XX\n") || return;

        # if there, write the kw line
        {
            my( $kw );
            if ( my $func = $self->_kw_generation_func ) {
                $kw = &{$func}($seq);
            } elsif ( $seq->can('keywords') ) {
                $kw = $seq->keywords;
            }
            if (defined $kw) {
                $self->_write_line_EMBL_regex("KW   ", "KW   ", $kw, '\s+|$', 80) || return; #'
                $self->_print( "XX\n") || return;
            }
        }

        # Organism lines

        if ($seq->can('species') && (my $spec = $seq->species)) {
            my @class = $spec->classification();
            shift @class;       # get rid of species name. Some embl files include
                                # the species name in the OC lines, but this seems
                                # more like an error than something we need to
                                # emulate
            my $OS = $spec->scientific_name;
            if ($spec->common_name) {
                $OS .= ' ('.$spec->common_name.')';
            }
            $self->_print("OS   $OS\n") || return;
            my $OC = join('; ', reverse(@class)) .'.';
            $self->_write_line_EMBL_regex("OC   ","OC   ",$OC,'; |$',80) || return;
            if ($spec->organelle) {
                $self->_write_line_EMBL_regex("OG   ","OG   ",$spec->organelle,'; |$',80) || return;
            }
            my $ncbi_taxid = $spec->ncbi_taxid;
            if ($ncbi_taxid) {
                $self->_print("OX   NCBI_TaxID=$ncbi_taxid\n") || return;
            }
            $self->_print("XX\n") || return;
        }
        # Reference lines
        my $t = 1;
        if ( $seq->can('annotation') && defined $seq->annotation ) {
            foreach my $ref ( $seq->annotation->get_Annotations('reference') ) {
                $self->_print( "RN   [$t]\n") || return;

                # Having no RP line is legal, but we need both
                # start and end for a valid location.
                if ($ref->comment) {
                    $self->_write_line_EMBL_regex("RC   ", "RC   ", $ref->comment, '\s+|$', 80) || return; #'
                }
                my $start = $ref->start;
                my $end   = $ref->end;
                if ($start and $end) {
                    $self->_print( "RP   $start-$end\n") || return;
                } elsif ($start or $end) {
                    $self->throw("Both start and end are needed for a valid RP line.".
                                 "  Got: start='$start' end='$end'");
                }

                if (my $med = $ref->medline) {
                    $self->_print( "RX   MEDLINE; $med.\n") || return;
                }
                if (my $pm = $ref->pubmed) {
                    $self->_print( "RX   PUBMED; $pm.\n") || return;
                }
                my $authors = $ref->authors;
                $authors =~ s/([\w\.]) (\w)/$1#$2/g;  # add word wrap protection char '#'

                $self->_write_line_EMBL_regex("RA   ", "RA   ",
                                              $authors . ";",
                                              '\s+|$', 80) || return; #'

                # If there is no title to the reference, it appears
                # as a single semi-colon.  All titles must end in
                # a semi-colon.
                my $ref_title = $ref->title || '';
                $ref_title =~ s/[\s;]*$/;/;
                $self->_write_line_EMBL_regex("RT   ", "RT   ", $ref_title,    '\s+|$', 80) || return; #'
                $self->_write_line_EMBL_regex("RL   ", "RL   ", $ref->location, '\s+|$', 80) || return; #'
                $self->_print("XX\n") || return;
                $t++;
            }

            # DB Xref lines
            if (my @db_xref = $seq->annotation->get_Annotations('dblink') ) {
                for my $dr (@db_xref) {
                    my $db_name = $dr->database;
                    my $prim    = $dr->primary_id;

                    my $opt     = $dr->optional_id || '';
                    my $line = $opt ? "$db_name; $prim; $opt." : "$db_name; $prim.";
                    $self->_write_line_EMBL_regex("DR   ", "DR   ", $line, '\s+|$', 80) || return; #'
                }
                $self->_print("XX\n") || return;
            }
            
            # Comment lines
            foreach my $comment ( $seq->annotation->get_Annotations('comment') ) {
                $self->_write_line_EMBL_regex("CC   ", "CC   ", $comment->text, '\s+|$', 80) || return; #'
                $self->_print("XX\n") || return;
            }
        }
        # "\\s\+\|\$"

        ## FEATURE TABLE

        $self->_print("FH   Key             Location/Qualifiers\n") || return;
        $self->_print("FH\n") || return;

        my @feats = $seq->can('top_SeqFeatures') ? $seq->top_SeqFeatures : ();
        if ($feats[0]) {
            if ( defined $self->_post_sort ) {
                # we need to read things into an array.
                # Process. Sort them. Print 'em

                my $post_sort_func = $self->_post_sort();
                my @fth;

                foreach my $sf ( @feats ) {
                    push(@fth,Bio::SeqIO::FTHelper::from_SeqFeature($sf,$seq));
                }

                @fth = sort { &$post_sort_func($a,$b) } @fth;

                foreach my $fth ( @fth ) {
                    $self->_print_EMBL_FTHelper($fth) || return;
                }
            } else {
                # not post sorted. And so we can print as we get them.
                # lower memory load...

                foreach my $sf ( @feats ) {
                    my @fth = Bio::SeqIO::FTHelper::from_SeqFeature($sf,$seq);
                    foreach my $fth ( @fth ) {
                        if ( $fth->key eq 'CONTIG') {
                            $self->_show_dna(0);
                        }
                        $self->_print_EMBL_FTHelper($fth) || return;
                    }
                }
            }
        }

        if ( $self->_show_dna() == 0 ) {
            $self->_print( "//\n") || return;
            return;
        }
        $self->_print( "XX\n") || return;

        # finished printing features.

	# print contig if present : bug#2982
	if ( $seq->can('annotation') && defined $seq->annotation) {
	    foreach my $ctg ( $seq->annotation->get_Annotations('contig') ) {
		if ($ctg->value) {
		    $self->_write_line_EMBL_regex("CO   ","CO   ", $ctg->value,
						  '[,]|$', 80) || return;
		}
	    }
	}
	# print sequence lines only if sequence is present! bug#2982
	if (length($str)) {
	    $str =~ tr/A-Z/a-z/;

	    # Count each nucleotide
	    my $alen = $str =~ tr/a/a/;
	    my $clen = $str =~ tr/c/c/;
	    my $glen = $str =~ tr/g/g/;
	    my $tlen = $str =~ tr/t/t/;
	    
	    my $len = $seq->length();
	    my $olen = $seq->length() - ($alen + $tlen + $clen + $glen);
	    if ( $olen < 0 ) {
		$self->warn("Weird. More atgc than bases. Problem!");
	    }
	    
	    $self->_print("SQ   Sequence $len BP; $alen A; $clen C; $glen G; $tlen T; $olen other;\n") || return;

	    my $nuc = 60;       # Number of nucleotides per line
	    my $whole_pat = 'a10' x 6; # Pattern for unpacking a whole line
	    my $out_pat   = 'A11' x 6; # Pattern for packing a line
	    my $length = length($str);
	    
	    # Calculate the number of nucleotides which fit on whole lines
	    my $whole = int($length / $nuc) * $nuc;

	    # Print the whole lines
	    my( $i );
	    for ($i = 0; $i < $whole; $i += $nuc) {
		my $blocks = pack $out_pat,
                unpack $whole_pat,
		substr($str, $i, $nuc);
		$self->_print(sprintf("     $blocks%9d\n", $i + $nuc)) || return;
	    }

	    # Print the last line
	    if (my $last = substr($str, $i)) {
		my $last_len = length($last);
		my $last_pat = 'a10' x int($last_len / 10) .'a'. $last_len % 10;
		my $blocks = pack $out_pat,
                unpack($last_pat, $last);
		$self->_print(sprintf("     $blocks%9d\n", $length)) ||
		    return;         # Add the length to the end
	    }
	}
	    
	$self->_print( "//\n") || return;
	
	$self->flush if $self->_flush_on_write && defined $self->_fh;
    }
    return 1;
}

=head2 _print_EMBL_FTHelper

 Title   : _print_EMBL_FTHelper
 Usage   :
 Function: Internal function
 Returns : 1 if writing suceeded, otherwise undef
 Args    :


=cut

sub _print_EMBL_FTHelper {
    my ($self,$fth) = @_;

    if ( ! ref $fth || ! $fth->isa('Bio::SeqIO::FTHelper') ) {
        $fth->warn("$fth is not a FTHelper class. Attempting to print, but there could be tears!");
    }


    #$self->_print( "FH   Key             Location/Qualifiers\n");
    #$self->_print( sprintf("FT   %-15s  %s\n",$fth->key,$fth->loc));
    # let
    if ( $fth->key eq 'CONTIG' ) {
        $self->_print("XX\n") || return;
        $self->_write_line_EMBL_regex("CO   ",
                                      "CO   ",$fth->loc,
                                      '\,|$',80) || return; #'
        return 1;
    }
    $self->_write_line_EMBL_regex(sprintf("FT   %-15s ",$fth->key),
                                  "FT                   ",$fth->loc,
                                  '\,|$',80) || return; #'
    foreach my $tag ( keys %{$fth->field} ) {
        if ( ! defined $fth->field->{$tag} ) {
            next;
        }
        foreach my $value ( @{$fth->field->{$tag}} ) {
            $value =~ s/\"/\"\"/g;
            if ($value eq "_no_value") {
                $self->_write_line_EMBL_regex("FT                   ",
                                              "FT                   ",
                                              "/$tag",'.|$',80) || return; #'
            }
            # there are almost 3x more quoted qualifier values and they
            # are more common too so we take quoted ones first
            #
            # Long qualifiers, that will be line wrapped, are always quoted
            elsif (!$FTQUAL_NO_QUOTE{$tag} or length("/$tag=$value")>=60) {
                my $pat = $value =~ /\s/ ? '\s|\-|$' : '.|\-|$';
                $self->_write_line_EMBL_regex("FT                   ",
                                              "FT                   ",
                                              "/$tag=\"$value\"",$pat,80) || return;
            } else {
                $self->_write_line_EMBL_regex("FT                   ",
                                              "FT                   ",
                                              "/$tag=$value",'.|$',80) || return; #'
                                          }
            }
        }

        return 1;
    }



=head2 _read_EMBL_Contig()

 Title   : _read_EMBL_Contig
 Usage   : 
 Function: convert CO lines into annotations
 Returns : 
 Args    : 

=cut

sub _read_EMBL_Contig {
    my ($self, $buffer) = @_;
    my @ret;
    if ( $$buffer !~ /^CO/ ) {
        warn("Not parsing line '$$buffer' which maybe important");
    }
    $self->_pushback($$buffer);
    while ( defined ($_ = $self->_readline) ) {
	/^C/ || last;
	/^CO\s+(.*)/ && do {
	push @ret, Bio::Annotation::SimpleValue->new( -tagname => 'contig',
						      -value => $1);
	};
    }
    $$buffer = $_;
    return @ret;

}
#'
=head2 _read_EMBL_References

 Title   : _read_EMBL_References
 Usage   :
 Function: Reads references from EMBL format. Internal function really
 Example :
 Returns :
 Args    :


=cut

sub _read_EMBL_References {
    my ($self,$buffer) = @_;
    my (@refs);

    # assume things are starting with RN

    if ( $$buffer !~ /^RN/ ) {
        warn("Not parsing line '$$buffer' which maybe important");
    }
    my $b1;
    my $b2;
    my $title;
    my $loc;
    my $au;
    my $med;
    my $pm;
    my $com;

    while ( defined ($_ = $self->_readline) ) {
        /^R/ || last;
        /^RP   (\d+)-(\d+)/ && do {$b1=$1;$b2=$2;};
        /^RX   MEDLINE;\s+(\d+)/ && do {$med=$1};
        /^RX   PUBMED;\s+(\d+)/ && do {$pm=$1};
        /^RA   (.*)/ && do {
            $au = $self->_concatenate_lines($au,$1); next;
        };
        /^RT   (.*)/ && do {
            $title = $self->_concatenate_lines($title,$1); next;
        };
        /^RL   (.*)/ && do {
            $loc = $self->_concatenate_lines($loc,$1); next;
        };
        /^RC   (.*)/ && do {
            $com = $self->_concatenate_lines($com,$1); next;
        };
    }

    my $ref = Bio::Annotation::Reference->new();
    $au =~ s/;\s*$//g;
    $title =~ s/;\s*$//g;

    $ref->start($b1);
    $ref->end($b2);
    $ref->authors($au);
    $ref->title($title);
    $ref->location($loc);
    $ref->medline($med);
    $ref->comment($com);
    $ref->pubmed($pm);

    push(@refs,$ref);
    $$buffer = $_;

    return @refs;
}

=head2 _read_EMBL_Species

 Title   : _read_EMBL_Species
 Usage   :
 Function: Reads the EMBL Organism species and classification
           lines.
 Example :
 Returns : A Bio::Species object
 Args    : a reference to the current line buffer, accession number

=cut

sub _read_EMBL_Species {
    my( $self, $buffer, $acc ) = @_;
    my $org;

    $_ = $$buffer;
    my( $sub_species, $species, $genus, $common, $sci_name, $class_lines );
    while (defined( $_ ||= $self->_readline )) {
        if (/^OS\s+(.+)/) {
            $sci_name .= ($sci_name) ? ' '.$1 : $1;
        } elsif (s/^OC\s+(.+)$//) {
            $class_lines .= $1;
        } elsif (/^OG\s+(.*)/) {
            $org = $1;
        } else {
            last;
        }

        $_ = undef;             # Empty $_ to trigger read of next line
    }

#    $$buffer = $_;
	$self->_pushback($_);
	
    $sci_name =~ s{\.$}{};
    $sci_name || return;

    # Convert data in classification lines into classification array.
    # only split on ';' or '.' so that classification that is 2 or more words
    # will still get matched, use map() to remove trailing/leading/intervening
    # spaces
    my @class = map { s/^\s+//; s/\s+$//; s/\s{2,}/ /g; $_; } split /(?<!subgen)[;\.]+/, $class_lines;

    # do we have a genus?
    my $possible_genus = $class[-1];
    $possible_genus .= "|$class[-2]" if $class[-2];
    if ($sci_name =~ /^($possible_genus)/) {
        $genus = $1;
        ($species) = $sci_name =~ /^$genus\s+(.+)/;
    } else {
        $species = $sci_name;
    }

    # Don't make a species object if it is "Unknown" or "None"
    if ($genus) {
        return if $genus =~ /^(Unknown|None)$/i;
    }

    # is this organism of rank species or is it lower?
    # (doesn't catch everything, but at least the guess isn't dangerous)
    if ($species =~ /subsp\.|var\./) {
        ($species, $sub_species) = $species =~ /(.+)\s+((?:subsp\.|var\.).+)/;
    }

    # sometimes things have common name in brackets, like
    # Schizosaccharomyces pombe (fission yeast), so get rid of the common
    # name bit. Probably dangerous if real scientific species name ends in
    # bracketed bit.
    unless ($class[-1] eq 'Viruses') {
        ($species, $common) = $species =~ /^(.+)\s+\((.+)\)$/;
        $sci_name =~ s/\s+\(.+\)$// if $common;
    }

    # Bio::Species array needs array in Species -> Kingdom direction
    unless ($class[-1] eq $sci_name) {
        push(@class, $sci_name);
    }
    @class = reverse @class;

    # do minimal sanity checks before we hand off to Bio::Species which won't
    # be able to give informative throw messages if it has to throw because
    # of problems here
    $self->throw("$acc seems to be missing its OS line: invalid.") unless $sci_name;
    my %names;
    foreach my $i (0..$#class) {
        my $name = $class[$i];
        $names{$name}++;
        # this code breaks examples like: Xenopus (Silurana) tropicalis
        # commenting out, see bug 3158
        
        #if ($names{$name} > 1 && ($name ne $class[$i - 1])) {
        #    $self->warn("$acc seems to have an invalid species classification:$name ne $class[$i - 1]");
        #}
    }
    my $make = Bio::Species->new();
    $make->scientific_name($sci_name);
    $make->classification(@class);
    unless ($class[-1] eq 'Viruses') {
        $make->genus($genus) if $genus;
        $make->species($species) if $species;
        $make->sub_species($sub_species) if $sub_species;
        $make->common_name($common) if $common;
    }
    $make->organelle($org) if $org;
    return $make;
}

=head2 _read_EMBL_DBLink

 Title   : _read_EMBL_DBLink
 Usage   :
 Function: Reads the EMBL database cross reference ("DR") lines
 Example :
 Returns : A list of Bio::Annotation::DBLink objects
 Args    :

=cut

sub _read_EMBL_DBLink {
    my( $self,$buffer ) = @_;
    my( @db_link );

    $_ = $$buffer;
    while (defined( $_ ||= $self->_readline )) {
        if ( /^DR   ([^\s;]+);\s*([^\s;]+);?\s*([^\s;]+)?\.$/) {
        my ($databse, $prim_id, $sec_id) = ($1,$2,$3);
        my $link = Bio::Annotation::DBLink->new(-database    => $databse,
                            -primary_id  => $prim_id,
                            -optional_id => $sec_id);

            push(@db_link, $link);
    } else {
            last;
        }
        $_ = undef;             # Empty $_ to trigger read of next line
    }

    $$buffer = $_;
    return @db_link;
}

=head2 _read_EMBL_TaxID_DBLink

 Title   : _read_EMBL_TaxID_DBLink
 Usage   :
 Function: Reads the EMBL database cross reference to NCBI TaxID ("OX") lines
 Example :
 Returns : A list of Bio::Annotation::DBLink objects
 Args    :

=cut

sub _read_EMBL_TaxID_DBLink {
    my( $self,$buffer ) = @_;
    my( @db_link );

    $_ = $$buffer;
    while (defined( $_ ||= $self->_readline )) {
        if ( /^OX   (\S+)=(\d+);$/ ) {
            my ($databse, $prim_id) = ($1,$2);
            my $link = Bio::Annotation::DBLink->new(-database    => $databse,
                                                    -primary_id  => $prim_id,);
            push(@db_link, $link);
        } else {
            last;
        }
        $_ = undef;             # Empty $_ to trigger read of next line
    }

    $$buffer = $_;
    return @db_link;
}

=head2 _filehandle

 Title   : _filehandle
 Usage   : $obj->_filehandle($newval)
 Function:
 Example :
 Returns : value of _filehandle
 Args    : newvalue (optional)


=cut

sub _filehandle{
    my ($obj,$value) = @_;
    if ( defined $value) {
        $obj->{'_filehandle'} = $value;
    }
    return $obj->{'_filehandle'};

}

=head2 _read_FTHelper_EMBL

 Title   : _read_FTHelper_EMBL
 Usage   : _read_FTHelper_EMBL($buffer)
 Function: reads the next FT key line
 Example :
 Returns : Bio::SeqIO::FTHelper object
 Args    : filehandle and reference to a scalar


=cut

sub _read_FTHelper_EMBL {
    my ($self,$buffer) = @_;

    my ($key,                   # The key of the feature
        $loc,                   # The location line from the feature
        @qual,                  # An arrray of lines making up the qualifiers
       );

    if ($$buffer =~ /^FT\s{3}(\S+)\s+(\S+)/ ) {
        $key = $1;
        $loc = $2;
        # Read all the lines up to the next feature
        while ( defined($_ = $self->_readline) ) {
            if (/^FT(\s+)(.+?)\s*$/) {
                # Lines inside features are preceeded by 19 spaces
                # A new feature is preceeded by 3 spaces
                if (length($1) > 4) {
                    # Add to qualifiers if we're in the qualifiers
                    if (@qual) {
                        push(@qual, $2);
                    }
                    # Start the qualifier list if it's the first qualifier
                    elsif (substr($2, 0, 1) eq '/') {
                        @qual = ($2);
                    }
                    # We're still in the location line, so append to location
                    else {
                        $loc .= $2;
                    }
                } else {
                    # We've reached the start of the next feature
                    last;
                }
            } else {
                # We're at the end of the feature table
                last;
            }
        }
    } elsif ( $$buffer =~ /^CO\s+(\S+)/) {
    $key = 'CONTIG';
    $loc = $1;
    # Read all the lines up to the next feature
    while ( defined($_ = $self->_readline) ) {
        if (/^CO\s+(\S+)\s*$/) {
        $loc .= $1;
        } else {
        # We've reached the start of the next feature
        last;
        }
    }
    } else {
        # No feature key
        return;
    }

    # Put the first line of the next feature into the buffer
    $$buffer = $_;

    # Make the new FTHelper object
    my $out = Bio::SeqIO::FTHelper->new();
    $out->verbose($self->verbose());
    $out->key($key);
    $out->loc($loc);

    # Now parse and add any qualifiers.  (@qual is kept
    # intact to provide informative error messages.)
  QUAL: for (my $i = 0; $i < @qual; $i++) {
        $_ = $qual[$i];
        my( $qualifier, $value ) = m{^/([^=]+)(?:=(.+))?}
            or $self->throw("Can't see new qualifier in: $_\nfrom:\n"
                            . join('', map "$_\n", @qual));
        if (defined $value) {
            # Do we have a quoted value?
            if (substr($value, 0, 1) eq '"') {
                # Keep adding to value until we find the trailing quote
                # and the quotes are balanced
              QUOTES:
                while ($value !~ /"$/ or $value =~ tr/"/"/ % 2) { #"
                    $i++;
                    my $next = $qual[$i];
                    if (!defined($next)) {
                        $self->warn("Unbalanced quote in:\n".join("\n", @qual).
                                    "\nAdding quote to close...".
                                    "Check sequence quality!");
                        $value .= '"';
                        last QUOTES;
                    }

                    # Protein sequence translations need to be joined without spaces,
                    # other qualifiers need those.
                    if ($qualifier eq "translation") {
                        $value .= $next;
                    } else {
                        $value .= " $next";
                    }
                }
                # Trim leading and trailing quotes
                $value =~ s/^"|"$//g;
                # Undouble internal quotes
                $value =~ s/""/"/g; #"
            }
        } else {
            $value = '_no_value';
        }

        # Store the qualifier
        $out->field->{$qualifier} ||= [];
        push(@{$out->field->{$qualifier}},$value);
    }

    return $out;
}

=head2 _write_line_EMBL

 Title   : _write_line_EMBL
 Usage   :
 Function: internal function
 Example :
 Returns : 1 if writing suceeded, else undef
 Args    :


=cut

sub _write_line_EMBL {
    my ($self,$pre1,$pre2,$line,$length) = @_;

    $length || $self->throw("Miscalled write_line_EMBL without length. Programming error!");
    my $subl = $length - length $pre2;
    my $linel = length $line;
    my $i;

    my $sub = substr($line,0,$length - length $pre1);

    $self->_print( "$pre1$sub\n") || return;

    for ($i= ($length - length $pre1);$i < $linel;) {
        $sub = substr($line,$i,($subl));
        $self->_print( "$pre2$sub\n") || return;
        $i += $subl;
    }

    return 1;
}

=head2 _write_line_EMBL_regex

 Title   : _write_line_EMBL_regex
 Usage   :
 Function: internal function for writing lines of specified
           length, with different first and the next line
           left hand headers and split at specific points in the
           text
 Example :
 Returns : nothing
 Args    : file handle, first header, second header, text-line, regex for line breaks, total line length


=cut

sub _write_line_EMBL_regex {
    my ($self,$pre1,$pre2,$line,$regex,$length) = @_;

    #print STDOUT "Going to print with $line!\n";

    $length || $self->throw("Programming error - called write_line_EMBL_regex without length.");

    my $subl = $length - (length $pre1) -1 ;
    my( @lines );

  CHUNK: while($line) {
        foreach my $pat ($regex, '[,;\.\/-]\s|'.$regex, '[,;\.\/-]|'.$regex) {
            if ($line =~ m/^(.{0,$subl})($pat)(.*)/ ) {
                my $l = $1.$2;
                $l =~ s/#/ /g  # remove word wrap protection char '#'
                    if $pre1 eq "RA   ";
                my $newl = $3;
                $line = substr($line,length($l));
                # be strict about not padding spaces according to
                # genbank format
                $l =~ s/\s+$//;
                next CHUNK if ($l eq '');
                push(@lines, $l);
                next CHUNK;
            }
        }
        # if we get here none of the patterns matched $subl or less chars
        $self->warn("trouble dissecting \"$line\"\n     into chunks ".
                    "of $subl chars or less - this tag won't print right");
        # insert a space char to prevent infinite loops
        $line = substr($line,0,$subl) . " " . substr($line,$subl);
    }
    my $s = shift @lines;
    ($self->_print("$pre1$s\n") || return) if $s;
    foreach my $s ( @lines ) {
        $self->_print("$pre2$s\n") || return;
    }

    return 1;
}

=head2 _post_sort

 Title   : _post_sort
 Usage   : $obj->_post_sort($newval)
 Function:
 Returns : value of _post_sort
 Args    : newvalue (optional)


=cut

sub _post_sort{
    my $obj = shift;
    if ( @_ ) {
        my $value = shift;
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

sub _show_dna{
    my $obj = shift;
    if ( @_ ) {
        my $value = shift;
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

sub _id_generation_func{
    my $obj = shift;
    if ( @_ ) {
        my $value = shift;
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

sub _ac_generation_func{
    my $obj = shift;
    if ( @_ ) {
        my $value = shift;
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

sub _sv_generation_func{
    my $obj = shift;
    if ( @_ ) {
        my $value = shift;
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

sub _kw_generation_func{
    my $obj = shift;
    if ( @_ ) {
        my $value = shift;
        $obj->{'_kw_generation_func'} = $value;
    }
    return $obj->{'_kw_generation_func'};

}

1;
