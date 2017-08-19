#
# BioPerl module for Bio::SeqIO::swiss
#
# Copyright Elia Stupka
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::swiss - Swissprot sequence input/output stream

=head1 SYNOPSIS

It is probably best not to use this object directly, but
rather go through the SeqIO handler system:

    use Bio::SeqIO;

    $stream = Bio::SeqIO->new(-file => $filename,
                              -format => 'swiss');

    while ( my $seq = $stream->next_seq() ) {
       # do something with $seq
    }

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from Swiss-Pprot flat
file databases.

There is a lot of flexibility here about how to dump things which needs
to be documented.

=head2 GN (Gene name) line management details

A Uniprot/Swiss-Prot entry holds information on one protein
sequence. If that sequence is identical across genes and species, they
are all merged into one entry. This creates complex needs for several
annotation fields in swiss-prot format.

The latest syntax for GN line is described in the user manual:

  http://www.expasy.ch/sprot/userman.html#GN_line

Each of the possibly multiple genes in an entry can have Name,
Synonyms (only if there is a name), OrderedLocusNames (names from
genomic sequences) and ORFNames (temporary or cosmid names). "Name"
here really means "symbol". This complexity is now dealt with the
following way:

A new Bio::AnnotationI class was created in order to store the
data in tag-value pairs.  This class (Bio::Annotation::TagTree)
is stored in the Bio::Annotation::Collection object and is
accessed like all other annotations. The tag name is 'gene_name'.

There is a single Bio::Annotation::TagTree per sequence record, which
corresponds to the original class that stored this data
(Bio::Annotation::StructuredValue).  Depending on how we progress
this may change to represent each group of gene names.

For now, to access the gene name tree annotation, one uses the below method:

   my ($gene) = $seq->annotation->get_Annotations('gene_name');

If you are only interested in displaying the values, value() returns a
string with similar formatting.

There are several ways to get directly at the information you want if you
know the element (tag) for the data.  For gene names all data is stored with
the element-tag pairs:

  "element1=tag1, tag2, tag3; element2=tag4, tag5;"

This normally means the element will be 'Name', 'Synonyms', etc. and the
gene names the values.  Using findval(), you can do the following:

  # grab a flattened list of all gene names
  my @names = $ann->findval('Name');

  # or iterated through the nodes and grab the name for each group
  for my $node ($ann->findnode('gene_name')) {
     my @names = $node->findval('Name');
  }

The current method for parsing gene name data (and reconstructing gene name
output) is very generic. This is somewhat preemptive if, for instance, UniProt
decides to update and add another element name to the current ones using the
same formatting layout. Under those circumstances, one can iterate through the
tag tree in a safe way and retrieve all node data like so.

  # retrieve the gene name nodes (groups like names, synonyms, etc).
  for my $ann ($seq->annotation->get_Annotations('gene_name')) {

      # each gene name group
      for my $node ($ann->findnode('gene_name')) {
          print "Gene name:\n";

          # each gene name node (tag => value pair)
          for my $n ($node->children) {
              print "\t".$n->element.": ".$n->children."\n";
          }
      }
  }

For more uses see Bio::Annotation::TagTree.

Since Uniprot/Swiss-Prot format have been around for quite some time, the
parser is also able to read in the older GN line syntax where genes
are separated by AND and various symbols by OR. The first symbol is
taken to be the 'Name' and the remaining ones are stored as 'Synonyms'.

Also, for UniProt output we support using other Bio::AnnotationI, but in this
case we only use the stringified version of the annotation. This is to allow for
backwards compatibility with code that previously used
Bio::Annotation::SimpleValue or other Bio::AnnotationI classes.

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

If you want to output annotations in Swissprot format they need to be
stored in a Bio::Annotation::Collection object which is accessible
through the Bio::SeqI interface method L<annotation()|annotation>.

The following are the names of the keys which are polled from a
L<Bio::Annotation::Collection> object.

 reference   - Should contain Bio::Annotation::Reference objects
 comment     - Should contain Bio::Annotation::Comment objects
 dblink      - Should contain Bio::Annotation::DBLink objects
 gene_name   - Should contain Bio::Annotation::SimpleValue object

=back

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions,
preferably to one of the Bioperl mailing lists.
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
the bugs and their resolution.
Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Elia Stupka

Email elia@tll.org.sg

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::swiss;
use vars qw(@Unknown_names @Unknown_genus);
use strict;
use Bio::SeqIO::FTHelper;
use Bio::SeqFeature::Generic;
use Bio::Species;
use Bio::Tools::SeqStats;
use Bio::Seq::SeqFactory;
use Bio::Annotation::Collection;
use Bio::Annotation::Comment;
use Bio::Annotation::Reference;
use Bio::Annotation::DBLink;
use Bio::Annotation::SimpleValue;
use Bio::Annotation::TagTree;

use base qw(Bio::SeqIO);

our $LINE_LENGTH = 76;

# this is for doing species name parsing
@Unknown_names=('other', 'unidentified',
                'unknown organism', 'not specified',
                'not shown', 'Unspecified', 'Unknown',
                'None', 'unclassified', 'unidentified organism',
                'not supplied'
               );
# dictionary of synonyms for taxid 32644
# all above can be part of valid species name
@Unknown_genus = qw(unknown unclassified uncultured unidentified);

# if there are any other gene name tags, they are added to the end
our @GENE_NAME_ORDER = qw(Name Synonyms OrderedLocusNames ORFNames);

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
    my ($pseq,$c,$line,$name,$desc,$acc,$seqc,$mol,$div, $sptr,$seq_div,
        $date,$comment,@date_arr);
    my $genename = "";
    my ($annotation, %params, @features) = ( Bio::Annotation::Collection->new());

    local $_;

    1 while defined($_ = $self->_readline) && /^\s+$/;
    return unless defined $_ && /^ID\s/;

    # fixed to allow _DIVISION to be optional for bug #946
    # see bug report for more information
    #
    # 9/6/06 Note: Swiss/TrEMBL sequences have no division acc. to UniProt
    # release notes; this is fixed to simplify the regex parsing
    # STANDARD (SwissProt) and PRELIMINARY (TrEMBL) added to namespace()
    unless(  m{^
               ID              \s+     #
               (\S+)           \s+     #  $1  entryname
               ([^\s;]+);      \s+     #  $2  DataClass
               (?:PRT;)?       \s+     #  Molecule Type (optional)
               [0-9]+[ ]AA     \.      #  Sequencelength (capture?)
               $
           }ox ) {
            # I couldn't find any new current UniProt sequences
            # that matched this format:
            # || m/^ID\s+(\S+)\s+(_([^\s_]+))? /ox ) {
        $self->throw("swissprot stream with no ID. Not swissprot in my book");
    }
    ($name, $seq_div) = ($1, $2);
    $params{'-namespace'} =
        ($seq_div eq 'Reviewed'   || $seq_div eq 'STANDARD')     ? 'Swiss-Prot' :
        ($seq_div eq 'Unreviewed' || $seq_div eq 'PRELIMINARY')  ? 'TrEMBL'     :
         $seq_div;
    # we shouldn't be setting the division, but for now...
    my ($junk, $division) = split q(_), $name;
    $params{'-division'} = $division;
    $params{'-alphabet'} = 'protein';
    # this is important to have the id for display in e.g. FTHelper, otherwise
    # you won't know which entry caused an error
    $params{'-display_id'} = $name;

    BEFORE_FEATURE_TABLE :
          while ( defined($_ = $self->_readline) ) {
              # Exit at start of Feature table and at the sequence at the
              # latest HL 05/11/2000
              last if( /^(FT|SQ)/ );

              # Description line(s)
              if (/^DE\s+(\S.*\S)/) {
                  $desc .= $desc ? " $1" : $1;
              }
              #Gene name
              elsif (/^GN\s+(.*)/) {
                  $genename .= " " if $genename;
                  $genename .= $1;
              }
              #accession number(s)
              elsif ( /^AC\s+(.+)/) {
                  my @accs = split(/[; ]+/, $1); # allow space in addition
                  $params{'-accession_number'} = shift @accs
                      unless defined $params{'-accession_number'};
                  push @{$params{'-secondary_accessions'}}, @accs;
              }
              #date and sequence version
              elsif ( /^DT\s+(.*)/ ) {
                  my $line = $1;
                  my ($date, $version) = split(' ', $line, 2);
                  $date =~ tr/,//d; # remove comma if new version
                  if ($version =~ /\(Rel\. (\d+), Last sequence update\)/ || # old
                      /sequence version (\d+)/) { #new
                      my $update = Bio::Annotation::SimpleValue->new
                          (-tagname    => 'seq_update',
                           -value      => $1
                          );
                      $annotation->add_Annotation($update);
                  } elsif ($version =~ /\(Rel\. (\d+), Last annotation update\)/ || #old
                           /entry version (\d+)/) { #new
                      $params{'-version'} = $1;
                  }
                  push @{$params{'-dates'}}, $date;
              }
              # Evidence level
              elsif ( /^PE\s+(.*)/ ) {
                  my $line = $1;
                  $line =~ s/;\s*//; # trim trailing semicolon and any spaces at the end of the line
                  my $evidence = Bio::Annotation::SimpleValue->new
                      (-tagname   => 'evidence',
                       -value     => $line
                      );
                  $annotation->add_Annotation($evidence);
              }
              # Organism name and phylogenetic information
              elsif (/^O[SCG]/) {
                  my $species = $self->_read_swissprot_Species($_);
                  $params{'-species'}= $species;
                  # now we are one line ahead -- so continue without reading the next
                  # line   HL 05/11/2000
              }
              # References
              elsif (/^R/) {
                  my $refs = $self->_read_swissprot_References($_);
                  foreach my $r (@$refs) {
                      $annotation->add_Annotation('reference',$r);
                  }
              }
              # Comments
              elsif (/^CC\s{3}(.*)/) {
                  $comment .= $1;
                  $comment .= "\n";
                  while (defined ($_ = $self->_readline) && /^CC\s{3}(.*)/ ) {
                      $comment .= $1 . "\n";
                  }

                  # note: don't try to process comments here -- they may contain
                  # structure. LP 07/30/2000

                  my $commobj = Bio::Annotation::Comment->new(-tagname => 'comment',
                                                              -text    => $comment);
                  $annotation->add_Annotation('comment',$commobj);
                  $comment = "";
                  $self->_pushback($_);
              }
              #DBLinks
              # old regexp
              # /^DR\s+(\S+)\;\s+(\S+)\;\s+(\S+)[\;\.](.*)$/) {
              # new regexp from Andreas Kahari  bug #1584
              elsif (/^DR\s+(\S+)\;\s+(\S+)\;\s+([^;]+)[\;\.](.*)$/) {
                  my ($database,$primaryid,$optional,$comment) = ($1,$2,$3,$4);

                  # drop leading and training spaces and trailing .
                  $comment =~ s/\.\s*$//;
                  $comment =~ s/^\s+//;

                  my $dblinkobj =  Bio::Annotation::DBLink->new
                      (-database    => $database,
                       -primary_id  => $primaryid,
                       -optional_id => $optional,
                       -comment     => $comment,
                       -tagname     => 'dblink',
                      );

                  $annotation->add_Annotation('dblink',$dblinkobj);
              }
              #keywords
              elsif ( /^KW\s+(.*)$/ ) {
                  my @kw = split(/\s*\;\s*/,$1);
                  defined $kw[-1] && $kw[-1] =~ s/\.$//;
                  push @{$params{'-keywords'}}, @kw;
              }
          }
    # process and parse the gene name line if there was one (note: we
    # can't do this above b/c GN may be multi-line and we can't
    # unequivocally determine whether we've seen the last GN line in
    # the new format)
    if ($genename) {
        my @stags;
        if ($genename =~ /\w=\w/) {
            # new format (e.g., Name=RCHY1; Synonyms=ZNF363, CHIMP)
            for my $n (split(m{\s+and\s+},$genename)) {
                my @genenames;
                for my $section (split(m{\s*;\s*},$n)) {
                    my ($tag, $rest) = split("=",$section);
                    $rest ||= '';
                    for my $val (split(m{\s*,\s*},$rest)) {
                        push @genenames, [$tag => $val];
                    }
                }
                push @stags, ['gene_name' => \@genenames];
            }
        } else {
            # old format
            for my $section (split(/ AND /, $genename)) {
                my @genenames;
                $section =~ s/[\(\)\.]//g;
                my @names = split(m{\s+OR\s+}, $section);
                push @genenames, ['Name' => shift @names];
                push @genenames, map {['Synonyms' => $_]} @names;
                push @stags, ['gene_name' => \@genenames]            
            }
        } #use Data::Dumper; print Dumper $gn, $genename;# exit;
        my $gn = Bio::Annotation::TagTree->new(-tagname => 'gene_name',
                                               -value => ['gene_names' => \@stags]);
        $annotation->add_Annotation('gene_name', $gn);
    }

    FEATURE_TABLE :
          # if there is no feature table, or if we've got beyond, exit loop or don't
          # even enter    HL 05/11/2000
          while (defined $_ && /^FT/ ) {
              my $ftunit = $self->_read_FTHelper_swissprot($_);

              # process ftunit
              # when parsing of the line fails we get undef returned
              if ($ftunit) {
                  push(@features,
                       $ftunit->_generic_seqfeature($self->location_factory(),
                                                    $params{'-seqid'}, "SwissProt"));
              } else {
                  $self->warn("failed to parse feature table line for seq " .
                              $params{'-display_id'}. "\n$_");
              }
              $_ = $self->_readline;
          }
    while ( defined($_) && ! /^SQ/ ) {
        $_ = $self->_readline;
    }
    $seqc = "";
    while ( defined ($_ = $self->_readline) ) {
        last if m{^//};
        s/[^A-Za-z]//g;
        $seqc .= uc($_);
    }

    my $seq=  $self->sequence_factory->create
        (-verbose  => $self->verbose,
         %params,
         -seq      => $seqc,
         -desc     => $desc,
         -features => \@features,
         -annotation => $annotation,
        );

    # The annotation doesn't get added by the contructor
    $seq->annotation($annotation);

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

        if ( ! ref $seq || ! $seq->isa('Bio::SeqI') ) {
            $self->warn(" $seq is not a SeqI compliant module. Attempting to dump, but may fail!");
        }

        my $i;
        my $str = $seq->seq;

        my $div;
        my $ns = ($seq->can('namespace')) && $seq->namespace();
        my $len = $seq->length();

        if ( !$seq->can('division') || ! defined ($div = $seq->division()) ) {
            $div = 'UNK';
        }

        # namespace dictates database, takes precedent over division. Sorry!
        if (defined($ns) && $ns ne '') {
            $div = ($ns eq 'Swiss-Prot') ? 'Reviewed'    :
                ($ns eq 'TrEMBL')     ? 'Unreviewed' :
                    $ns;
        } else {
            $ns = 'Swiss-Prot';
            # division not reset; acts as fallback
        }

        $self->warn("No whitespace allowed in SWISS-PROT display id [". $seq->display_id. "]")
            if $seq->display_id =~ /\s/;

        my $temp_line;
        if ( $self->_id_generation_func ) {
            $temp_line = &{$self->_id_generation_func}($seq);
        } else {
            #$temp_line = sprintf ("%10s     STANDARD;      %3s;   %d AA.",
            #            $seq->primary_id()."_".$div,$mol,$len);
            # Reconstructing the ID relies heavily upon the input source having
            # been in a format that is parsed as this routine expects it -- that is,
            # by this module itself. This is bad, I think, and immediately breaks
            # if e.g. the Bio::DB::GenPept module is used as input.
            # Hence, switch to display_id(); _every_ sequence is supposed to have
            # this. HL 2000/09/03
            # Changed to reflect ID line changes in UniProt
            # Oct 2006 - removal of molecule type - see bug 2134
            $temp_line = sprintf ("%-24s%-12s%9d AA.",
                                  $seq->display_id(), $div.';', $len);
        }

        $self->_print( "ID   $temp_line\n");

        # if there, write the accession line
        local($^W) = 0;         # supressing warnings about uninitialized fields

        if ( $self->_ac_generation_func ) {
            $temp_line = &{$self->_ac_generation_func}($seq);
            $self->_print( "AC   $temp_line\n");
        }
        elsif ($seq->can('accession_number') ) {
            my $ac_line = $seq->accession_number;
            if ($seq->can('get_secondary_accessions') ) {
                foreach my $sacc ($seq->get_secondary_accessions) {
                    $ac_line .= "; ". $sacc;;
                }
                $ac_line .= ";";
            }

            $self->_write_line_swissprot_regex("AC   ","AC   ",$ac_line,
                                               "\\s\+\|\$",$LINE_LENGTH);
        }
        # otherwise - cannot print <sigh>


        # Date lines and sequence versions (changed 6/15/2006)
        # This is rebuilt from scratch using the current SwissProt/UniProt format
        if ( $seq->can('get_dates') ) {
            my @dates =  $seq->get_dates();
            my $ct = 1;
            my $seq_version = $seq->version;
            my ($update_version) = $seq->annotation->get_Annotations("seq_update");
            foreach my $dt (@dates) {
                $self->_write_line_swissprot_regex("DT   ","DT   ",
                                                   $dt.', integrated into UniProtKB/'.$ns.'.',
                                                   "\\s\+\|\$",$LINE_LENGTH) if $ct == 1;
                $self->_write_line_swissprot_regex("DT   ","DT   ",
                                                   $dt.", sequence version ".$update_version->display_text.'.',
                                                   "\\s\+\|\$",$LINE_LENGTH) if $ct == 2;
                $self->_write_line_swissprot_regex("DT   ","DT   ",
                                                   $dt.", entry version $seq_version.",
                                                   "\\s\+\|\$",$LINE_LENGTH) if $ct == 3;
                $ct++;
            }
        }

        #Definition lines
        $self->_write_line_swissprot_regex("DE   ","DE   ",$seq->desc(),"\\s\+\|\$",$LINE_LENGTH);

        #Gene name; print out new format
        foreach my $gene ( my @genes = $seq->annotation->get_Annotations('gene_name') ) {
            # gene is a Bio::Annotation::TagTree;
            if ($gene->isa('Bio::Annotation::TagTree')) {
                my @genelines;
                for my $node ($gene->findnode('gene_name')) {
                    # check for Name and Synonym first, then the rest get tagged on
                    my $geneline = "GN   ";
                    my %genedata = $node->hash;
                    for my $tag (@GENE_NAME_ORDER) {
                        if (exists $genedata{$tag}) {
                            $geneline .= (ref $genedata{$tag} eq 'ARRAY') ?
                                "$tag=".join(', ',@{$genedata{$tag}})."; " :
                                "$tag=$genedata{$tag}; ";
                            delete $genedata{$tag};
                        }
                    }
                    # add rest
                    for my $tag (sort keys %genedata) {
                        $geneline .= (ref $genedata{$tag} eq 'ARRAY') ?
                            "$tag=".join(', ',@{$genedata{$tag}})."; " :
                            "$tag=$genedata{$tag}; ";
                        delete $genedata{$tag};
                    }
                    push @genelines, "$geneline\n";
                }
                $self->_print(join("GN   and\n",@genelines));
            } else { # fall back to getting stringified output
                $self->_write_line_swissprot_regex("GN   ","GN   ",
                                                   $gene->display_text,
                                                   "\\s\+\|\$",
                                                   $LINE_LENGTH);
            }
        }

        # Organism lines
        if ($seq->can('species') && (my $spec = $seq->species)) {
            my @class = $spec->classification();
            shift(@class);
            my $species = $spec->species;
            my $genus = $spec->genus;
            my $OS = $spec->scientific_name;
            if ($class[-1] =~ /viruses/i) {
                $OS = $species;
                $OS .=  " ". $spec->sub_species if $spec->sub_species;
            }
            foreach (($spec->variant, $spec->common_name)) {
                $OS .= " ($_)" if $_;
            }
            $self->_print( "OS   $OS.\n");
            my $OC = join('; ', reverse(@class)) .'.';
            $self->_write_line_swissprot_regex("OC   ","OC   ",$OC,"\; \|\$",$LINE_LENGTH);
            if ($spec->organelle) {
                $self->_write_line_swissprot_regex("OG   ","OG   ",$spec->organelle,"\; \|\$",$LINE_LENGTH);
            }
            if ($spec->ncbi_taxid) {
                $self->_print("OX   NCBI_TaxID=".$spec->ncbi_taxid.";\n");
            }
        }

        # Reference lines
        my $t = 1;
        foreach my $ref ( $seq->annotation->get_Annotations('reference') ) {
            $self->_print( "RN   [$t]\n");
            # changed by lorenz 08/03/00
            # j.gilbert and h.lapp agreed that the rp line in swissprot seems
            # more like a comment than a parseable value, so print it as is
            if ($ref->rp) {
                $self->_write_line_swissprot_regex("RP   ","RP   ",$ref->rp,
                                                   "\\s\+\|\$",$LINE_LENGTH);
            }
            if ($ref->comment) {
                $self->_write_line_swissprot_regex("RC   ","RC   ",$ref->comment,
                                                   "\\s\+\|\$",$LINE_LENGTH);
            }
            if ($ref->medline or $ref->pubmed or $ref->doi) {
                # new RX format in swissprot LP 09/17/00
                # RX line can now have a DOI, Heikki 13 Feb 2008

                my $line;
                $line .= "MEDLINE=". $ref->medline. '; ' if $ref->medline;
                $line .= "PubMed=". $ref->pubmed. '; ' if $ref->pubmed;
                $line .= "DOI=". $ref->doi. '; ' if $ref->doi;
                chop $line;

                $self->_write_line_swissprot_regex("RX   ","RX   ",
                                                   $line,
                                                   "\\s\+\|\$",$LINE_LENGTH);

            }
            my $author = $ref->authors .';' if($ref->authors);
            my $title = $ref->title .';' if( $ref->title);
            my $rg = $ref->rg . ';' if $ref->rg;
            $author =~ s/([\w\.]) (\w)/$1#$2/g;  # add word wrap protection char '#'

            $self->_write_line_swissprot_regex("RG   ","RG   ",$rg,"\\s\+\|\$",$LINE_LENGTH) if $rg;
            $self->_write_line_swissprot_regex("RA   ","RA   ",$author,"\\s\+\|\$",$LINE_LENGTH) if $author;
            $self->_write_line_swissprot_regex("RT   ","RT   ",$title,'[\s\-]+|$',$LINE_LENGTH) if $title;
            $self->_write_line_swissprot_regex("RL   ","RL   ",$ref->location,"\\s\+\|\$",$LINE_LENGTH);
            $t++;
        }

        # Comment lines

        foreach my $comment ( $seq->annotation->get_Annotations('comment') ) {
            foreach my $cline (split ("\n", $comment->text)) {
                while (length $cline > 74) {
                    $self->_print("CC   ",(substr $cline,0,74),"\n");
                    $cline = substr $cline,74;
                }
                $self->_print("CC   ",$cline,"\n");
            }
        }

        # Database xref lines

        foreach my $dblink ( $seq->annotation->get_Annotations('dblink') ) {
            my ($primary_id) = $dblink->primary_id;
	
            if (defined($dblink->comment) && ($dblink->comment) ) {
                $self->_print("DR   ",$dblink->database,"; ",$primary_id,"; ",
                              $dblink->optional_id,"; ",$dblink->comment,".\n");
            } elsif ($dblink->optional_id) {
                $self->_print("DR   ",$dblink->database,"; ",
                              $primary_id,"; ",
                              $dblink->optional_id,".\n");
            } else {
                $self->_print("DR   ",$dblink->database,
                              "; ",$primary_id,"; ","-.\n");
            }
        }

        # Evidence lines

        foreach my $evidence ( $seq->annotation->get_Annotations('evidence') ) {
            $self->_print("PE   ",$evidence->value,";\n");
        }

        # if there, write the kw line
        {
            my $kw;
            if ( my $func = $self->_kw_generation_func ) {
                $kw = &{$func}($seq);
            } elsif ( $seq->can('keywords') ) {
                $kw = $seq->keywords;
                if ( ref($kw) =~ /ARRAY/i ) {
                    $kw = join("; ", @$kw);
                }
                $kw .= '.' if $kw and $kw !~ /\.$/ ;
            }
            $kw =~ s/([\w\.]) (\w)/$1#$2/g;  # add word wrap protection char '#'
            $self->_write_line_swissprot_regex("KW   ","KW   ",
                                               $kw, "\\s\+\|\$",$LINE_LENGTH)
                if $kw;
        }

        #Check if there is seqfeatures before printing the FT line
        my @feats = $seq->can('top_SeqFeatures') ? $seq->top_SeqFeatures : ();
        if ($feats[0]) {
            if ( defined $self->_post_sort ) {

                # we need to read things into an array. Process. Sort them. Print 'em

                my $post_sort_func = $self->_post_sort();
                my @fth;

                foreach my $sf ( @feats ) {
                    push(@fth,Bio::SeqIO::FTHelper::from_SeqFeature($sf,$seq));
                }
                @fth = sort { &$post_sort_func($a,$b) } @fth;

                foreach my $fth ( @fth ) {
                    $self->_print_swissprot_FTHelper($fth);
                }
            } else {
                # not post sorted. And so we can print as we get them.
                # lower memory load...

                foreach my $sf ( @feats ) {
                    my @fth = Bio::SeqIO::FTHelper::from_SeqFeature($sf,$seq);
                    foreach my $fth ( @fth ) {
                        if ( ! $fth->isa('Bio::SeqIO::FTHelper') ) {
                            $sf->throw("Cannot process FTHelper... $fth");
                        }
                        $self->_print_swissprot_FTHelper($fth);
                    }
                }
            }

            if ( $self->_show_dna() == 0 ) {
                return;
            }
        }
        # finished printing features.

        # molecular weight
        my $mw = ${Bio::Tools::SeqStats->get_mol_wt($seq->primary_seq)}[0];
        # checksum
        # was crc32 checksum, changed it to crc64
        my $crc64 = $self->_crc64(\$str);
        $self->_print( sprintf("SQ   SEQUENCE  %4d AA;  %d MW;  %16s CRC64;\n",
                               $len,$mw,$crc64));
        $self->_print( "    ");
        my $linepos;
        for ($i = 0; $i < length($str); $i += 10) {
            $self->_print( " ", substr($str,$i,10));
            $linepos += 11;
            if ( ($i+10)%60 == 0 && (($i+10) < length($str))) {
                $self->_print( "\n    ");
            }
        }
        $self->_print( "\n//\n");

        $self->flush if $self->_flush_on_write && defined $self->_fh;
        return 1;
    }
}

# Thanks to James Gilbert for the following two. LP 08/01/2000

=head2 _generateCRCTable

 Title   : _generateCRCTable
 Usage   :
 Function:
 Example :
 Returns :
 Args    :


=cut

sub _generateCRCTable {
  # 10001000001010010010001110000100
  # 32
    my $poly = 0xEDB88320;
    my ($self) = shift;

    $self->{'_crcTable'} = [];
    foreach my $i (0..255) {
        my $crc = $i;
        for (my $j=8; $j > 0; $j--) {
            if ($crc & 1) {
                $crc = ($crc >> 1) ^ $poly;
            } else {
                $crc >>= 1;
            }
        }
        ${$self->{'_crcTable'}}[$i] = $crc;
    }
}


=head2 _crc32

 Title   : _crc32
 Usage   :
 Function:
 Example :
 Returns :
 Args    :


=cut

sub _crc32 {
    my( $self, $str ) = @_;

    $self->throw("Argument to crc32() must be ref to scalar")
        unless ref($str) eq 'SCALAR';

    $self->_generateCRCTable() unless exists $self->{'_crcTable'};

    my $len = length($$str);

    my $crc = 0xFFFFFFFF;
    for (my $i = 0; $i < $len; $i++) {
        # Get upper case value of each letter
        my $int = ord uc substr $$str, $i, 1;
        $crc = (($crc >> 8) & 0x00FFFFFF) ^
            ${$self->{'_crcTable'}}[ ($crc ^ $int) & 0xFF ];
    }
    return $crc;
}

=head2 _crc64

 Title   : _crc64
 Usage   :
 Function:
 Example :
 Returns :
 Args    :


=cut

sub _crc64{
    my ($self, $sequence) = @_;
    my $POLY64REVh = 0xd8000000;
    my @CRCTableh = 256;
    my @CRCTablel = 256;
    my $initialized;

    my $seq = $$sequence;

    my $crcl = 0;
    my $crch = 0;
    if (!$initialized) {
        $initialized = 1;
        for (my $i=0; $i<256; $i++) {
            my $partl = $i;
            my $parth = 0;
            for (my $j=0; $j<8; $j++) {
                my $rflag = $partl & 1;
                $partl >>= 1;
                $partl |= (1 << 31) if $parth & 1;
                $parth >>= 1;
                $parth ^= $POLY64REVh if $rflag;
            }
            $CRCTableh[$i] = $parth;
            $CRCTablel[$i] = $partl;
        }
    }

    foreach (split '', $seq) {
        my $shr = ($crch & 0xFF) << 24;
        my $temp1h = $crch >> 8;
        my $temp1l = ($crcl >> 8) | $shr;
        my $tableindex = ($crcl ^ (unpack "C", $_)) & 0xFF;
        $crch = $temp1h ^ $CRCTableh[$tableindex];
        $crcl = $temp1l ^ $CRCTablel[$tableindex];
    }
    my $crc64 = sprintf("%08X%08X", $crch, $crcl);
    return $crc64;
}

=head2 _print_swissprot_FTHelper

 Title   : _print_swissprot_FTHelper
 Usage   :
 Function:
 Example :
 Returns :
 Args    :


=cut

sub _print_swissprot_FTHelper {
    my ($self,$fth,$always_quote) = @_;
    $always_quote ||= 0;
    my ($start,$end) = ('?', '?');

    if ( ! ref $fth || ! $fth->isa('Bio::SeqIO::FTHelper') ) {
        $fth->warn("$fth is not a FTHelper class. ".
                   "Attempting to print, but there could be tears!");
    }
    my $desc = "";

    for my $tag ( qw(description gene note product) ) {
        if ( exists $fth->field->{$tag} ) {
            $desc = @{$fth->field->{$tag}}[0].".";
            last;
        }
    }
    $desc =~ s/\.$//;

    my $ftid = "";
    if ( exists $fth->field->{'FTId'} ) {
        $ftid = @{$fth->field->{'FTId'}}[0]. '.';
    }

    my $key =substr($fth->key,0,8);
    my $loc = $fth->loc;
    if ( $loc =~ /(\?|\d+|\>\d+|<\d+)?\.\.(\?|\d+|<\d+|>\d+)?/ ) {
        $start = $1 if defined $1;
        $end = $2 if defined $2;

        # to_FTString only returns one value when start == end, #JB955
        # so if no match is found, assume it is both start and end #JB955
    } elsif ( $loc =~ /join\((\d+)((?:,\d+)+)?\)/) {
        my @y = ($1);
        if ( defined( my $m = $2) ) {
            $m =~ s/^\,//;
            push @y, split(/,/,$m);
        }
        for my $x ( @y ) {
            $self->_write_line_swissprot_regex(
                                               sprintf("FT   %-8s %6s %6s       ",
                                                       $key,
                                                       $x ,$x),
                                               "FT                                ",
                                               $desc.'.','\s+|$',$LINE_LENGTH);
        }
        return;
    } else {
        $start = $end = $fth->loc;
    }
    if ($desc) {
        $self->_write_line_swissprot_regex(sprintf("FT   %-8s %6s %6s       ",
                                                   $key,
                                                   $start ,$end),
                                           "FT                                ",
                                           $desc. '.', '\s+|$', $LINE_LENGTH);
    } else {                    #HELIX and STRAND do not have descriptions
        $self->_write_line_swissprot_regex(sprintf("FT   %-8s %6s %6s",
                                                   $key,
                                                   $start ,$end),
                                           "FT                         ",
                                           ' ', '\s+|$', $LINE_LENGTH);
    }


    if ($ftid) {
        $self->_write_line_swissprot_regex("FT                                ",
                                           "FT                                ",
                                           "/FTId=$ftid",'.|$',$LINE_LENGTH);

    }

}
#'

=head2 _read_swissprot_References

 Title   : _read_swissprot_References
 Usage   :
 Function: Reads references from swissprot format. Internal function really
 Example :
 Returns :
 Args    :


=cut

sub _read_swissprot_References{
    my ($self,$line) = @_;
    my ($b1, $b2, $rp, $rg, $title, $loc, $au, $med, $com, $pubmed, $doi);
    my @refs;
    local $_ = $line;
    while ( defined $_ ) {
        if ( /^[^R]/ || /^RN/ ) {
            if ( $rp ) {
                $rg =~ s/;\s*$//g if defined($rg);
                if (defined($au)) {
                    $au =~ s/;\s*$//;
                } else {
                    $au = $rg;
                }
                $title =~ s/;\s*$//g if defined($title);
                push @refs, Bio::Annotation::Reference->new
                    (-title   => $title,
                     -start   => $b1,
                     -end     => $b2,
                     -authors => $au,
                     -location=> $loc,
                     -medline => $med,
                     -pubmed  => $pubmed,
                     -doi     => $doi,
                     -comment => $com,
                     -rp      => $rp,
                     -rg      => $rg,
                     -tagname => 'reference',
                    );
                # reset state for the next reference
                $rp = '';
            }
            if (index($_,'R') != 0) {
                $self->_pushback($_); # want this line to go back on the list
                last;           # may be the safest exit point HL 05/11/2000
            }
            # don't forget to reset the state for the next reference
            $b1 = $b2 = $rg = $med = $com = $pubmed = $doi = undef;
            $title = $loc = $au = undef;
        } elsif ( /^RP\s{3}(.+? OF (\d+)-(\d+).*)/) {
            $rp  .= $1;
            $b1   = $2;
            $b2   = $3;
        } elsif ( /^RP\s{3}(.*)/) {
            if ($rp) {
                $rp .= " ".$1;
            } else {
                $rp = $1;
            }
        } elsif (/^RX\s{3}(.*)/) { # each reference can have only one RX line
            my $line = $1;
            $med = $1 if $line =~ /MEDLINE=(\d+);/;
            $pubmed = $1 if $line =~ /PubMed=(\d+);/;
            $doi = $1 if $line =~ /DOI=(.+);/;
        } elsif ( /^RA\s{3}(.*)/ ) {
            $au .= $au ? " $1" : $1;
        } elsif ( /^RG\s{3}(.*)/ ) {
            $rg .= $rg ? " $1" : $1;
        } elsif ( /^RT\s{3}(.*)/ ) {
            if ($title) {
                my $tline = $1;
                $title .= ($title =~ /[\w;,:\?!]$/) ? " $tline" : $tline;
            } else {
                $title = $1;
            }
        } elsif (/^RL\s{3}(.*)/ ) {
            $loc .= $loc ? " $1" : $1;
        } elsif ( /^RC\s{3}(.*)/ ) {
            $com .= $com ? " $1" : $1;
        }
        $_ = $self->_readline;
    }
    return \@refs;
}


=head2 _read_swissprot_Species

 Title   : _read_swissprot_Species
 Usage   :
 Function: Reads the swissprot Organism species and classification
           lines.
             Able to deal with unconventional species names.
 Example : OS Unknown prokaryotic organism
             $genus = undef ; $species = Unknown prokaryotic organism
 Returns : A Bio::Species object
 Args    :

=cut

sub _read_swissprot_Species {
    my( $self,$line ) = @_;
    my $org;
    local $_ = $line;

    my( $sub_species, $species, $genus, $common, $variant, $ncbi_taxid, $sci_name, $class_lines, $descr );
    my $osline = "";
    my $do_genus_check = 1;
    while ( defined $_ ) {
        last unless /^O[SCGX]/;
        # believe it or not, but OS may come multiple times -- at this time
        # we can't capture multiple species
        if (/^OS\s+(\S.+)/ && (! defined($sci_name))) {
            $osline .= " " if $osline;
            $osline .= $1;
            if ($osline =~ s/(,|, and|\.)$//) {
                # OS lines are usually like:
                # Homo sapiens (human)
                # where we have $sci_name followed by $descr (common name) in
                # brackets, but we can also have:
                # Venerupis (Ruditapes) philippinarum
                # where we have brackets but they don't indicate a $descr
                if ($osline =~ /[^\(\)]+\(.+\)[^\(\)]+$/) {
                    #*** Danger! no idea if this will pick up some syntaxes for
                    #    common names as well)
                    $sci_name = $osline;
                    $sci_name =~ s/\.$//;
                    $descr = '';
                    $do_genus_check = 0;
                } else {
                    ($sci_name, $descr) = $osline =~ /(\S[^\(]+)(.*)/;
                }
                $sci_name =~ s/\s+$//;

                while ($descr =~ /\(([^\)]+)\)/g) {
                    my $item = $1;
                    # strain etc may not necessarily come first (yes, swissprot
                    # is messy)
                    if ((! defined($variant)) &&
                        (($item =~ /(^|[^\(\w])([Ss]train|isolate|serogroup|serotype|subtype|clone)\b/) ||
                         ($item =~ /^(biovar|pv\.|type\s+)/))) {
                        $variant = $item;
                    } elsif ($item =~ s/^subsp\.\s+//) {
                        if (! $sub_species) {
                            $sub_species = $item;
                        } elsif (! $variant) {
                            $variant = $item;
                        }
                    } elsif (! defined($common)) {
                        # we're only interested in the first common name
                        $common = $item;
                        if ((index($common, '(') >= 0) &&
                            (index($common, ')') < 0)) {
                            $common .= ')';
                        }
                    }
                }
            }
        } elsif (s/^OC\s+(\S.+)$//) {
            $class_lines .= $1;
        } elsif (/^OG\s+(.*)/) {
            $org = $1;
        } elsif (/^OX\s+(.*)/ && (! defined($ncbi_taxid))) {
            my $taxstring = $1;
            # we only keep the first one and ignore all others
            if ($taxstring =~ /NCBI_TaxID=([\w\d]+)/) {
                $ncbi_taxid = $1;
            } else {
                $self->throw("$taxstring doesn't look like NCBI_TaxID");
            }
        }
        $_ = $self->_readline;
    }
    $self->_pushback($_);       # pushback the last line because we need it

    $sci_name || return;

    # if the organism belongs to taxid 32644 then no Bio::Species object.
    return if grep { $_ eq $sci_name } @Unknown_names;

    # Convert data in classification lines into classification array.
    # Remove trailing . then split on ';' or '.;' so that classification that is 2
    # or more words will still get matched, use map() to remove trailing/leading/intervening
    # spaces
    $class_lines=~s/\.\s*$//;
    my @class = map { s/^\s+//; s/\s+$//; s/\s{2,}/ /g; $_; } split /[;\.]*;/, $class_lines;

    if ($class[0] =~ /viruses/i) {
        # viruses have different OS/OC syntax
        my @virusnames = split(/\s+/, $sci_name);
        $species = (@virusnames > 1) ? pop(@virusnames) : '';
        $genus = join(" ", @virusnames);
        $sub_species = $descr;
    } elsif ($do_genus_check) {
        # do we have a genus?
        my $possible_genus = $class[-1];
        $possible_genus .= "|$class[-2]" if $class[-2];
        if ($sci_name =~ /^($possible_genus)/) {
            $genus = $1;
            ($species) = $sci_name =~ /^$genus\s+(.+)/;
        } else {
            $species = $sci_name;
        }
        # is this organism of rank species or is it lower?
        # (doesn't catch everything, but at least the guess isn't dangerous)
        if ($species && $species =~ /subsp\.|var\./) {
            ($species, $sub_species) = $species =~ /(.+)\s+((?:subsp\.|var\.).+)/;
        }
    }

    # Bio::Species array needs array in Species -> Kingdom direction
    unless ($class[-1] eq $sci_name) {
        push(@class, $sci_name);
    }
    @class = reverse @class;

    my $taxon = Bio::Species->new();
    $taxon->scientific_name($sci_name);
    $taxon->classification(@class);
    $taxon->common_name($common) if $common;
    $taxon->sub_species($sub_species) if $sub_species;
    $taxon->organelle($org) if $org;
    $taxon->ncbi_taxid($ncbi_taxid) if $ncbi_taxid;
    $taxon->variant($variant) if $variant;

    # done
    return $taxon;
}

=head2 _filehandle

 Title   : _filehandle
 Usage   : $obj->_filehandle($newval)
 Function:
 Example :
 Returns : value of _filehandle
 Args    : newvalue (optional)


=cut

# inherited from SeqIO.pm ! HL 05/11/2000

=head2 _read_FTHelper_swissprot

 Title   : _read_FTHelper_swissprot
 Usage   : _read_FTHelper_swissprot(\$buffer)
 Function: reads the next FT key line
 Example :
 Returns : Bio::SeqIO::FTHelper object
 Args    :


=cut

sub _read_FTHelper_swissprot {
    my ($self,$line ) = @_;
    # initial version implemented by HL 05/10/2000
    # FIXME this may not be perfect, so please review
    # lots of cleaning up by JES 2004/07/01, still may not be perfect =)
    # FTId now sepated from description as a qualifier

    local $_ = $line;
    my ($key,                   # The key of the feature
        $loc,                   # The location line from the feature
        $desc,                  # The descriptive text
        $ftid,                  # feature Id is like a qualifier but there can be only one of them
       );
    if ( m/^FT\s{3}(\w+)\s+([\d\?\<]+)\s+([\d\?\>]+)\s*(.*)$/ox) {
        $key = $1;
        my $loc1 = $2;
        my $loc2 = $3;
        $loc = "$loc1..$loc2";
        if ($4 && (length($4) > 0)) {
            $desc = $4;
            chomp($desc);
        } else {
            $desc = "";
        }
    }

    while ( defined($_ = $self->_readline) && /^FT\s{20,}(\S.*)$/ ) {
        my $continuation_line = $1;
        if ( $continuation_line =~ /.FTId=(.*)\./ ) {
            $ftid=$1;
        }
        elsif ( $desc) {
            $desc .= " $continuation_line";
        } else {
            $desc = $continuation_line;
        }
        chomp $desc;
    }
    $self->_pushback($_);
    unless( $key ) {
        # No feature key. What's this?
        $self->warn("No feature key in putative feature table line: $line");
        return;
    }

    # Make the new FTHelper object
    my $out = Bio::SeqIO::FTHelper->new(-verbose => $self->verbose());
    $out->key($key);
    $out->loc($loc);

    # store the description if there is one
    if ( $desc && length($desc) ) {
        $desc =~ s/\.$//;
        push(@{$out->field->{"description"}}, $desc);
    }
    # Store the qualifier i.e. FTId
    if ( $ftid ) {
        push(@{$out->field->{"FTId"}}, $ftid);
    }
    return $out;
}


=head2 _write_line_swissprot

 Title   : _write_line_swissprot
 Usage   :
 Function: internal function
 Example :
 Returns :
 Args    :


=cut

sub _write_line_swissprot{
    my ($self,$pre1,$pre2,$line,$length) = @_;

    $length || $self->throw( "Miscalled write_line_swissprot without length. Programming error!");
    my $subl = $length - length $pre2;
    my $linel = length $line;
    my $i;

    my $sub = substr($line,0,$length - length $pre1);

    $self->_print( "$pre1$sub\n");

    for ($i= ($length - length $pre1);$i < $linel;) {
        $sub = substr($line,$i,($subl));
        $self->_print( "$pre2$sub\n");
        $i += $subl;
    }

}

=head2 _write_line_swissprot_regex

 Title   : _write_line_swissprot_regex
 Usage   :
 Function: internal function for writing lines of specified
           length, with different first and the next line
           left hand headers and split at specific points in the
           text
 Example :
 Returns : nothing
 Args    : file handle, first header, second header, text-line, regex for line breaks, total line length


=cut

sub _write_line_swissprot_regex {
    my ($self,$pre1,$pre2,$line,$regex,$length) = @_;

    #print STDOUT "Going to print with $line!\n";

    $length || $self->throw( "Miscalled write_line_swissprot without length. Programming error!");

    if ( length $pre1 != length $pre2 ) {
        $self->warn( "len 1 is ". length ($pre1) . " len 2 is ". length ($pre2) . "\n");
        $self->throw( "Programming error - cannot called write_line_swissprot_regex with different length \npre1 ($pre1) and \npre2 ($pre2) tags!");
    }

    my $subl = $length - (length $pre1) -1 ;

    my $first_line = 1;
    while ($line =~ m/(.{1,$subl})($regex)/g) {
        my $s = $1.$2;
        $s =~ s/([\w\.])#(\w)/$1 $2/g  # remove word wrap protection char '#'
            if $pre1 eq "RA   " or $pre1 eq "KW   ";
        # remove annoying extra spaces at the end of the wrapped lines
        substr($s, -1, 1, '') if substr($s, -1, 1) eq ' ';
        if ($first_line) {
            $self->_print( "$pre1$s\n");
            $first_line = 0;
        } else {
            $self->_print( "$pre2$s\n");
        }

    }
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
