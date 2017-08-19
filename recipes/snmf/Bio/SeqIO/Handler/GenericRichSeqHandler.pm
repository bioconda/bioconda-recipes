#
# BioPerl module for Bio::SeqIO::Handler::GenericRichSeqHandler
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Chris Fields
#
# Copyright Chris Fields
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::Handler::GenericRichSeqHandler - Bio::HandlerI-based
data handler for GenBank/EMBL/UniProt (and other) sequence data

=head1 SYNOPSIS

  # MyHandler is a GenericRichSeqHandler object.
  # inside a parser (driver) constructor....

  $self->seq_handler($handler || MyHandler->new(-format => 'genbank'));

  # in next_seq() in driver...

  $hobj = $self->seqhandler();

  # roll data up into hashref chunks, pass off into Handler for processing...

  $hobj->data_handler($data);

  # or retrieve Handler methods and pass data directly to Handler methods...

  my $hmeth = $hobj->handler_methods;

  if ($hmeth->{ $data->{NAME} }) {
      my $mth = $hmeth->{ $data->{NAME} };
      $hobj->$mth($data);
  }

=head1 DESCRIPTION

This is an experimental implementation of a sequence-based HandlerBaseI parser
and may change over time. It is possible (nay, likely) that the way handler
methods are set up will change over development to allow more flexibility.
Release pumpkins, please do not add this to a release until the API has settled.
It is also likely that write_seq() will not work properly for some data.

Standard Developer caveats:

Do not use for production purposes.
Not responsible for destroying (your data|computer|world).
Do not stare directly at GenericRichSeqHandler.
If GenericRichSeqHandler glows, back slowly away and call for help.

Consider yourself warned!

This class acts as a demonstration on how to handle similar data chunks derived
from Bio::SeqIO::gbdriver, Bio::SeqIO::embldriver, and Bio::SeqIO::swissdriver
using similar (or the same) handler methods.

The modules currently pass all previous tests in t/genbank.t, t/embl.t, and
t/swiss.t yet all use the same handler methods (the collected tests for handlers
can be found in t/Handler.t). Some tweaking of the methods themselves is
probably in order over the long run to ensure that data is consistently handled
for each parser.  Round-trip tests are probably in order here...

Though a Bio::Seq::SeqBuilder is employed for building sequence objects no
bypassing of data based on builder slots has been implemented (yet); this is
planned in the near future.

As a reminder: this is the current Annotation data chunk (via Data::Dumper):

  $VAR1 = {
            'NAME' => 'REFERENCE',
            'DATA' => '1  (bases 1 to 10001)'
            'AUTHORS' => 'International Human Genome Sequencing Consortium.'
            'TITLE' => 'The DNA sequence of Homo sapiens'
            'JOURNAL' => 'Unpublished (2003)'
          };
  ...

This is the current SeqFeature data chunk (again via Data::Dumper):

  $VAR1 = {
            'mol_type' => 'genomic DNA',
            'LOCATION' => '<1..>10001',
            'NAME' => 'FEATURES',
            'FEATURE_KEY' => 'source',
            'note' => 'Accession AL451081 sequenced by The Sanger Centre',
            'db_xref' => 'taxon:9606',
            'clone' => 'RP11-302I18',
            'organism' => 'Homo sapiens'
          };

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

=head1 AUTHOR - Chris Fields

Email cjfields at bioperl dot org

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal
methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::Handler::GenericRichSeqHandler;
use strict;
use warnings;

use Bio::SeqIO::FTHelper;
use Bio::Annotation::Collection;
use Bio::Annotation::DBLink;
use Bio::Annotation::Comment;
use Bio::Annotation::Reference;
use Bio::Annotation::Collection;
use Bio::Annotation::SimpleValue;
use Bio::Annotation::TagTree;
use Bio::SeqFeature::Generic;
use Bio::Species;
use Bio::Taxon;
use Bio::DB::Taxonomy;
use Bio::Factory::FTLocationFactory;
use Data::Dumper;

use base qw(Bio::Root::Root Bio::HandlerBaseI);

my %HANDLERS = (
    'genbank'   => {
        'LOCUS'         => \&_genbank_locus,
        'DEFINITION'    => \&_generic_description,
        'ACCESSION'     => \&_generic_accession,
        'VERSION'       => \&_generic_version,
        'KEYWORDS'      => \&_generic_keywords,
        'DBSOURCE'      => \&_genbank_dbsource,
        'DBLINK'        => \&_genbank_dbsource,
        'SOURCE'        => \&_generic_species,
        'REFERENCE'     => \&_generic_reference,
        'COMMENT'       => \&_generic_comment,
        'FEATURES'      => \&_generic_seqfeatures,
        'BASE'          => \&noop,    # this is generated from scratch
        'ORIGIN'        => \&_generic_seq,
        # handles anything else (WGS, WGS_SCAFLD, CONTIG, PROJECT)
        '_DEFAULT_'     => \&_generic_simplevalue, 
        },
    'embl'      => {
        'ID'            => \&_embl_id,
        'DT'            => \&_embl_date,
        'DR'            => \&_generic_dbsource,
        'SV'            => \&_generic_version,
        'RN'            => \&_generic_reference,
        'KW'            => \&_generic_keywords,
        'DE'            => \&_generic_description,
        'AC'            => \&_generic_accession,
        #'AH'            => \&noop, # TPA data not dealt with yet...
        #'AS'            => \&noop,
        'SQ'            => \&_generic_seq,
        'OS'            => \&_generic_species,
        'CC'            => \&_generic_comment,
        'FT'            => \&_generic_seqfeatures,
        # handles anything else (WGS, TPA, ANN...)
        '_DEFAULT_'     => \&_generic_simplevalue, 
        },
    'swiss'     => {
        'ID'            => \&_swiss_id,
        'DT'            => \&_swiss_date,
        'GN'            => \&_swiss_genename,
        'DR'            => \&_generic_dbsource,
        'RN'            => \&_generic_reference,
        'KW'            => \&_generic_keywords,
        'DE'            => \&_generic_description,
        'AC'            => \&_generic_accession,
        'SQ'            => \&_generic_seq,
        'OS'            => \&_generic_species,
        'CC'            => \&_generic_comment,
        'FT'            => \&_generic_seqfeatures,
        # handles anything else, though I don't know what...
        '_DEFAULT_'     => \&_generic_simplevalue,  
        },
    );

# can we do this generically?  Seems like a lot of trouble...
my %DBSOURCE = map {$_ => 1} qw(
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
    swissprot    GenBank    GenPept    REFSEQ    embl    PDB    UniProtKB);

my %NOPROCESS = map {$_ => 1} qw(DBSOURCE ORGANISM FEATURES);

our %VALID_ALPHABET = (
    'bp' => 'dna',
    'aa' => 'protein',
    'rc' => '' # rc = release candidate; file has no sequences
);

=head2 new

 Title   :  new
 Usage   :  
 Function:  
 Returns :  
 Args    :  -format    Sequence format to be mapped for handler methods
            -builder   Bio::Seq::SeqBuilder object (normally defined in
                       SequenceStreamI object implementation constructor)
 Throws  :  On undefined '-format' sequence format parameter
 Note    :  Still under heavy development

=cut

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    $self = {@args};
    bless $self,$class;
    my ($format, $builder) = $self->_rearrange([qw(FORMAT BUILDER)], @args);
    $self->throw("Must define sequence record format") if !$format;
    $self->format($format);
    $self->handler_methods();
    $builder  &&  $self->seqbuilder($builder);
    $self->location_factory();
    return $self;
}

=head1 L<Bio::HandlerBaseI> implementing methods

=head2 handler_methods

 Title   :  handler_methods
 Usage   :  $handler->handler_methods('GenBank')
            %handlers = $handler->handler_methods();
 Function:  Retrieve the handler methods used for the current format() in
            the handler.  This assumes the handler methods are already
            described in the HandlerI-implementing class.
 Returns :  a hash reference with the data type handled and the code ref
            associated with it.
 Args    :  [optional] String representing the sequence format.  If set here
            this will also set sequence_format()
 Throws  :  On unimplemented sequence format in %HANDLERS

=cut

sub handler_methods {
    my $self = shift;
    if (!($self->{'handlers'})) {
        $self->throw("No handlers defined for seqformat ",$self->format)
            unless exists $HANDLERS{$self->format};
        $self->{'handlers'} = $HANDLERS{$self->format};
    }
    return ($self->{'handlers'});
}

=head2 data_handler

 Title   :  data_handler
 Usage   :  $handler->data_handler($data)
 Function:  Centralized method which accepts all data chunks, then distributes
            to the appropriate methods for processing based on the chunk name
            from within the HandlerBaseI object.

            One can also use 
 Returns :  None
 Args    :  an hash ref containing a data chunk.  

=cut

sub data_handler {
    my ($self, $data) = @_;
    my $nm = $data->{NAME} || $self->throw("No name tag defined!");
    
    # this should handle data on the fly w/o caching; any caching should be 
    # done in the driver!
    my $method = (exists $self->{'handlers'}->{$nm}) ? ($self->{'handlers'}->{$nm}) :
                (exists $self->{'handlers'}->{'_DEFAULT_'}) ? ($self->{'handlers'}->{'_DEFAULT_'}) :
                undef;
    if (!$method) {
        $self->debug("No handler defined for $nm\n");
        return;
    };
    $self->$method($data);
}

=head2 reset_parameters

 Title   :  reset_parameters
 Usage   :  $handler->reset_parameters()
 Function:  Resets the internal cache of data (normally object parameters for
            a builder or factory)
 Returns :  None
 Args    :  None

=cut

sub reset_parameters {
    my $self = shift;
    $self->{'_params'} = undef;
}

=head2 format

 Title   :  format
 Usage   :  $handler->format('GenBank')
 Function:  Get/Set the format for the report/record being parsed. This can be
            used to set handlers in classes which are capable of processing
            similar data chunks from multiple driver modules.
 Returns :  String with the sequence format
 Args    :  [optional] String with the sequence format
 Note    :  The format may be used to set the handlers (as in the
            current GenericRichSeqHandler implementation)

=cut

sub format {
    my $self = shift;
    return $self->{'_seqformat'} = lc shift if @_;
    return $self->{'_seqformat'};
}

=head2 get_params

 Title   :  get_params
 Usage   :  $handler->get_params('-species')
 Function:  Convenience method used to retrieve the specified
            parameters from the internal parameter cache
 Returns :  Hash ref containing parameters requested and data as
            key-value pairs.  Note that some parameter values may be 
            objects, arrays, etc.
 Args    :  List (array) representing the parameters requested

=cut

sub get_params {
    my ($self, @ids) = @_;
    my %data;
    for my $id (@ids) {
        if (!index($id, '-')==0) {
            $id = '-'.$id ;
        }
        $data{$id} = $self->{'_params'}->{$id} if (exists $self->{'_params'}->{$id});
    }
    return \%data;
}

=head2 set_params

 Title   :  set_params
 Usage   :  $handler->set_param({'-species')
 Function:  Convenience method used to set specific parameters
 Returns :  None
 Args    :  Hash ref containing the data to be passed as key-value pairs

=cut

sub set_params {
    shift->throw('Not implemented yet!');
}

=head1 Methods unique to this implementation

=head2 seqbuilder

 Title   :  seqbuilder
 Usage   :  
 Function:  
 Returns :  
 Args    :
 Throws  :
 Note    :  

=cut

sub seqbuilder {
    my $self = shift;
    return $self->{'_seqbuilder'} = shift if @_;
    return $self->{'_seqbuilder'};
}

=head2 build_sequence

 Title   :  build_sequence
 Usage   :  
 Function:  
 Returns :  
 Args    :
 Throws  :
 Note    :  

=cut

sub build_sequence {
    my $self = shift;
    my $builder = $self->seqbuilder();
    my $seq;
    if (defined($self->{'_params'})) {
        $builder->add_slot_value(%{ $self->{'_params'} });
        $seq = $builder->make_object();
        $self->reset_parameters;
    }
    return $seq if $seq;
    return 0;
}

=head2 location_factory

 Title   :  location_factory
 Usage   :  
 Function:  
 Returns :  
 Args    :
 Throws  :
 Note    :  

=cut

sub location_factory {
    my ($self, $factory) = @_;
    if ($factory) {
        $self->throw("Must have a Bio::Factory::LocationFactoryI when ".
                     "explicitly setting factory()") unless
             (ref($factory) && $factory->isa('Bio::Factory::LocationFactoryI'));
        $self->{'_locfactory'} = $factory;
    } elsif (!defined($self->{'_locfactory'})) {
        $self->{'_locfactory'} = Bio::Factory::FTLocationFactory->new()
    }
    return $self->{'_locfactory'};
}

=head2 annotation_collection

 Title   :  annotation_collection
 Usage   :  
 Function:  
 Returns :  
 Args    :
 Throws  :
 Note    :  

=cut

sub annotation_collection {
    my ($self, $coll) = @_;
    if ($coll) {
        $self->throw("Must have Bio::AnnotationCollectionI ".
                     "when explicitly setting collection()")
            unless (ref($coll) && $coll->isa('Bio::AnnotationCollectionI'));
        $self->{'_params'}->{'-annotation'} = $coll;
    } elsif (!exists($self->{'_params'}->{'-annotation'})) {
        $self->{'_params'}->{'-annotation'} = Bio::Annotation::Collection->new()
    }
    return $self->{'_params'}->{'-annotation'};
}

####################### SEQUENCE HANDLERS #######################

# any sequence data
sub _generic_seq {
    my ($self, $data) = @_;
    $self->{'_params'}->{'-seq'} = $data->{DATA};
}

####################### RAW DATA HANDLERS #######################

# GenBank LOCUS line
sub _genbank_locus {
    my ($self, $data) = @_;
    my (@tokens) = split m{\s+}, $data->{DATA};
    my $display_id = shift @tokens;
    $self->{'_params'}->{'-display_id'} = $display_id;
    my $seqlength = shift @tokens;
    if (exists $VALID_ALPHABET{$seqlength}) {
        # moved one token too far.  No locus name?
        $self->warn("Bad LOCUS name?  Changing [".$self->{'_params'}->{'-display_id'}.
                    "] to 'unknown' and length to ".$self->{'_params'}->{'-display_id'});
        $self->{'_params'}->{'-length'} = $self->{'_params'}->{'-display_id'};
        $self->{'_params'}->{'-display_id'} = 'unknown';
        # add token back...
        unshift @tokens, $seqlength;
    } else {
    	$self->{'_params'}->{'-length'} = $seqlength;
    }
    my $alphabet = lc(shift @tokens);        
    $self->{'_params'}->{'-alphabet'} =
        (exists $VALID_ALPHABET{$alphabet}) ? $VALID_ALPHABET{$alphabet} :
                           $self->warn("Unknown alphabet: $alphabet");
    if (($self->{'_params'}->{'-alphabet'} eq 'dna') || (@tokens > 2)) {
	    $self->{'_params'}->{'-molecule'} = shift(@tokens);
	    my $circ = shift(@tokens);
	    if ($circ eq 'circular') {
		$self->{'_params'}->{'-is_circular'} = 1;
		$self->{'_params'}->{'-division'} = shift(@tokens);
	    } else {
				# 'linear' or 'circular' may actually be omitted altogether
		$self->{'_params'}->{'-division'} =
		    (CORE::length($circ) == 3 ) ? $circ : shift(@tokens);
	    }
	} else {
	    $self->{'_params'}->{'-molecule'} = 'PRT' if($self->{'_params'}->{'-alphabet'} eq 'aa');
	    $self->{'_params'}->{'-division'} = shift(@tokens);
	}
    my $date = join(' ', @tokens);
    # maybe use Date::Time for dates?
    if($date && $date =~ s{\s*((\d{1,2})-(\w{3})-(\d{2,4})).*}{$1}) {
        
	    if( length($date) < 11 ) {
            # improperly formatted date
            # But we'll be nice and fix it for them
            my ($d,$m,$y) = ($2,$3,$4);
            if( length($d) == 1 ) {
                $d = "0$d";
            }
            # guess the century here
            if( length($y) == 2 ) {
                if( $y > 60 ) { # arbitrarily guess that '60' means 1960
                $y = "19$y";
                } else {
                $y = "20$y";
                }
                $self->warn("Date was malformed, guessing the century for $date to be $y\n");
            }
            $self->{'_params'}->{'-dates'} = [join('-',$d,$m,$y)];
	    } else {
            $self->{'_params'}->{'-dates'} = [$date];
	    }
	}
}

# EMBL ID line
sub _embl_id {
    my ($self, $data) = @_;
    my $alphabet;
    my ($name, $sv, $topology, $mol, $div);
    my $line = $data->{DATA};
    #$self->debug("$line\n");
    my ($idtype) = $line =~ tr/;/;/;    
    if ( $idtype == 6) {   # New style headers contain exactly six semicolons.
    	# New style header (EMBL Release >= 87, after June 2006)
    	my $topology;
    	my $sv;
        
    	# ID   DQ299383; SV 1; linear; mRNA; STD; MAM; 431 BP.
		# This regexp comes from the new2old.pl conversion script, from EBI
    	if ($line =~ m/^(\w+);\s+SV (\d+); (\w+); ([^;]+); (\w{3}); (\w{3}); (\d+) \w{2}\./) {    
            ($name, $sv, $topology, $mol, $div) = ($1, $2, $3, $4, $6);
        } else {
            $self->throw("Unrecognized EMBL ID line:[$line]");
        }
    	if (defined($sv)) {
            $self->{'_params'}->{'-seq_version'} = $sv;
            $self->{'_params'}->{'-version'} = $sv;
    	}

    	if ($topology eq "circular") {
            $self->{'_params'}->{'-is_circular'} = 1;
    	}
	
        if (defined $mol ) {
            if ($mol =~ /DNA/) {
                $alphabet='dna';
            }
            elsif ($mol =~ /RNA/) {
                $alphabet='rna';
            }
            elsif ($mol =~ /AA/) {
                $alphabet='protein';
            }
        }
    } elsif ($idtype) { # has internal ';'
    	# Old style header (EMBL Release < 87, before June 2006)
        if ($line =~ m{^(\S+)[^;]*;\s+(\S+)[^;]*;\s+(\S+)[^;]*;}) {
            ($name, $mol, $div) = ($1, $2, $3);
            #$self->debug("[$name][$mol][$div]");
        } 

        if($mol) {
            if ( $mol =~ m{circular} ) {
                $self->{'_params'}->{'-is_circular'} = 1;
                $mol =~  s{circular }{};
            }
    	    if (defined $mol ) {
        		if ($mol =~ /DNA/) {
        		    $alphabet='dna';
        		}
        		elsif ($mol =~ /RNA/) {
        		    $alphabet='rna';
        		}
        		elsif ($mol =~ /AA/) {
        		    $alphabet='protein';
        		}
    	    }
    	}
    } else {
        $name = $data->{DATA};
    }
    unless( defined $name && length($name) ) {
        $name = "unknown_id";
    }
    $self->{'_params'}->{'-display_id'} = $name;
    $self->{'_params'}->{'-alphabet'} = $alphabet;
    $self->{'_params'}->{'-division'} = $div if $div;
    $self->{'_params'}->{'-molecule'} = $mol if $mol;
}

# UniProt/SwissProt ID line
sub _swiss_id {
    my ($self, $data) = @_;
    my ($name, $seq_div);
    if($data->{DATA} =~ m{^
                (\S+)           \s+     #  $1  entryname
                ([^\s;]+);      \s+     #  $2  DataClass
                (?:PRT;)?       \s+     #  Molecule Type (optional)
                [0-9]+[ ]AA     \.      #  Sequencelength (capture?)
                $
                }ox ) {
        ($name, $seq_div) = ($1, $2);
        $self->{'_params'}->{'-namespace'} =
          ($seq_div eq 'Reviewed'   || $seq_div eq 'STANDARD')     ? 'Swiss-Prot' :
          ($seq_div eq 'Unreviewed' || $seq_div eq 'PRELIMINARY')  ? 'TrEMBL'     :
           $seq_div;
        # we shouldn't be setting the division, but for now...
        my ($junk, $division) = split q(_), $name;
        $self->{'_params'}->{'-division'} = $division;
        $self->{'_params'}->{'-alphabet'} = 'protein';
        # this is important to have the id for display in e.g. FTHelper, otherwise
        # you won't know which entry caused an error
        $self->{'_params'}->{'-display_id'} = $name;
    } else {
        $self->throw("Unrecognized UniProt/SwissProt ID line:[".$data->{DATA}."]");
    }
}

# UniProt/SwissProt GN line
sub _swiss_genename {
    my ($self, $data) = @_;
    #$self->debug(Dumper($data));
    my $genename = $data->{DATA};
    my $gn;
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
        $self->annotation_collection->add_Annotation('gene_name', $gn);
    }
}

# GenBank VERSION line
# old EMBL SV line (now obsolete)
# UniProt/SwissProt?
sub _generic_version {
    my ($self, $data) = @_;
    my ($acc,$gi) = split(' ',$data->{DATA});
    if($acc =~ m{^\w+\.(\d+)}xmso) {
        $self->{'_params'}->{'-version'} = $1;
        $self->{'_params'}->{'-seq_version'} = $1;
    }
    if($gi && (index($gi,"GI:") == 0)) {
        $self->{'_params'}->{'-primary_id'} = substr($gi,3);
    }
}

# EMBL DT lines
sub _embl_date {
    my ($self, $data) = @_;
    while ($data->{DATA} =~ m{(\S+)\s\((.*?)\)}g) {
        my ($date, $version) = ($1, $2);
        $date =~ tr{,}{}d; # remove comma if new version
        if ($version =~ m{\(Rel\.\s(\d+),\sCreated\)}xmso ) {
            my $release = Bio::Annotation::SimpleValue->new(
                            -tagname    => 'creation_release',
                            -value      => $1
                            );
            $self->annotation_collection->add_Annotation($release);
        } elsif ($version =~ m{\(Rel\.\s(\d+),\sLast\supdated,\sVersion\s(\d+)\)}xmso ) {
            my $release = Bio::Annotation::SimpleValue->new(
                            -tagname    => 'update_release',
                            -value      => $1
                            );
            $self->annotation_collection->add_Annotation($release);
            my $update = Bio::Annotation::SimpleValue->new(
                           -tagname    => 'update_version',
                           -value      => $2
                           );
            $self->annotation_collection->add_Annotation($update);
        }
        push @{ $self->{'_params'}->{'-dates'} }, $date;
    }
}

# UniProt/SwissProt DT lines
sub _swiss_date {
    my ($self, $data) = @_;
    # swissprot
    my @dls = split m{\n}, $data->{DATA};
    for my $dl (@dls) {
        my ($date, $version) = split(' ', $dl, 2);
        $date =~ tr{,}{}d; # remove comma if new version    
        if ($version =~ m{\(Rel\. (\d+), Last sequence update\)} || # old
            $version =~ m{sequence version (\d+)\.}) { #new
        my $update = Bio::Annotation::SimpleValue->new(
                                    -tagname    => 'seq_update',
                                    -value      => $1
                                    );
        $self->annotation_collection->add_Annotation($update);
        } elsif ($version =~ m{\(Rel\. (\d+), Last annotation update\)} || #old
                 $version =~ m{entry version (\d+)\.}) { #new
            $self->{'_params'}->{'-version'} = $1;
            $self->{'_params'}->{'-seq_version'} = $1;
        }
        push @{ $self->{'_params'}->{'-dates'} }, $date;
    }
}

# GenBank KEYWORDS line
# EMBL KW line
# UniProt/SwissProt KW line
sub _generic_keywords {
    my ($self, $data) = @_;
    $data->{DATA} =~ s{\.$}{};
    my @kw = split m{\s*\;\s*}xo ,$data->{DATA};
    $self->{'_params'}->{'-keywords'} = \@kw;
}

# GenBank DEFINITION line
# EMBL DE line
# UniProt/SwissProt DE line
sub _generic_description {
    my ($self, $data) = @_;
    $self->{'_params'}->{'-desc'} = $data->{DATA};
}

# GenBank ACCESSION line
# EMBL AC line
# UniProt/SwissProt AC line
sub _generic_accession {
    my ($self, $data) = @_;
    my @accs = split m{[\s;]+}, $data->{DATA};
    $self->{'_params'}->{'-accession_number'} = shift @accs;
    $self->{'_params'}->{'-secondary_accessions'} = \@accs if @accs;
}

####################### SPECIES HANDLERS #######################

# uses Bio::Species
# GenBank SOURCE, ORGANISM lines
# EMBL O* lines
# UniProt/SwissProt O* lines
sub _generic_species {
    my ($self, $data) = @_;
    
    my $seqformat = $self->format;
    # if data is coming in from GenBank parser...
    if ($seqformat eq 'genbank' &&
        $data->{ORGANISM} =~ m{(.+?)\s(\S+;[^\n\.]+)}ox) {
        ($data->{ORGANISM}, $data->{CLASSIFICATION}) = ($1, $2);
    }
    
    # SwissProt stuff...
    # hybrid names in swissprot files are no longer valid per intergration into
    # UniProt. Files containing these have been split into separate entries, so
    # it is probably a good idea to update if one has these lingering around...

    my $taxid;
    if ($seqformat eq 'swiss') {
        if ($data->{DATA} =~ m{^([^,]+)}ox) {
            $data->{DATA} = $1;
        }
        if ($data->{CROSSREF} && $data->{CROSSREF} =~ m{NCBI_TaxID=(\d+)}) {
            $taxid = $1;
        }
    }
    
    my ($sl, $class, $sci_name) = ($data->{DATA},
                                   $data->{CLASSIFICATION},
                                   $data->{ORGANISM} || '');
    my ($organelle,$abbr_name, $common);    
    my @class = reverse split m{\s*;\s*}, $class;
    # have to treat swiss different from everything else...
    if ($sl =~ m{^(mitochondrion|chloroplast|plastid)?   # GenBank format
                \s*(.*?)
                \s*(?: \( (.*?) \) )?\.?$ 
         }xmso ){ 
        ($organelle, $abbr_name, $common) = ($1, $2, $3); # optional
    } else {
        $abbr_name = $sl;	# nothing caught; this is a backup!
    }
    # there is no 'abbreviated name' for EMBL
    $sci_name = $abbr_name if $seqformat ne 'genbank';
    $organelle ||= '';
    $common ||= '';
    $sci_name || return;
    unshift @class, $sci_name;
    # no genus/species parsing here; moving to Bio::Taxon-based taxonomy
    my $make = Bio::Species->new();
    $make->scientific_name($sci_name);
    $make->classification(@class) if @class > 0;
    $common    && $make->common_name( $common );
    $abbr_name && $make->name('abbreviated', $abbr_name);
    $organelle && $make->organelle($organelle);
    $taxid     && $make->ncbi_taxid($taxid);
    $self->{'_params'}->{'-species'} = $make;
}

####################### ANNOTATION HANDLERS #######################

# GenBank DBSOURCE line
sub _genbank_dbsource {
    my ($self, $data) = @_;
    my $dbsource = $data->{DATA};
    my $annotation = $self->annotation_collection;
    # deal with swissprot dbsources
    # we could possibly parcel these out to subhandlers...
    if( $dbsource =~ s/(UniProt(?:KB)|swissprot):\s+locus\s+(\S+)\,.+\n// ) {
        $annotation->add_Annotation
            ('dblink',
             Bio::Annotation::DBLink->new
             (-primary_id => $2,
              -database => $1,
              -tagname => 'dblink'));
        if( $dbsource =~ s/\s*created:\s+([^\.]+)\.\n// ) {
            $annotation->add_Annotation
            ('swissprot_dates',
             Bio::Annotation::SimpleValue->new
             (-tagname => 'date_created',
              -value => $1));
        }
        while( $dbsource =~ s/\s*(sequence|annotation)\s+updated:\s+([^\.]+)\.\n//g ) {
            $annotation->add_Annotation
            ('swissprot_dates',
             Bio::Annotation::SimpleValue->new
             (-tagname => 'date_updated',
              -value => $1));
        }
        $dbsource =~ s/\n/ /g;
        if( $dbsource =~ s/\s*xrefs:\s+((?:\S+,\s+)+\S+)\s+xrefs/xrefs/ ) {
            # will use $i to determine even or odd
            # for swissprot the accessions are paired
            my $i = 0;
            for my $dbsrc ( split(/,\s+/,$1) ) {
                if( $dbsrc =~ /(\S+)\.(\d+)/ || $dbsrc =~ /(\S+)/ ) {
                    my ($id,$version) = ($1,$2);
                    $version ='' unless defined $version;
                    my $db;
                    if( $id =~ /^\d\S{3}/) {
                        $db = 'PDB';
                    } else {
                        $db = ($i++ % 2 ) ? 'GenPept' : 'GenBank';
                    }
                    $annotation->add_Annotation
                    ('dblink',
                     Bio::Annotation::DBLink->new
                     (-primary_id => $id,
                      -version => $version,
                      -database => $db,
                      -tagname => 'dblink'));
                }
            }
        } elsif( $dbsource =~ s/\s*xrefs:\s+(.+)\s+xrefs/xrefs/i ) {
            # download screwed up and ncbi didn't put acc in for gi numbers
            my $i = 0;
            for my $id ( split(/\,\s+/,$1) ) {
            my ($acc,$db);
            if( $id =~ /gi:\s+(\d+)/ ) {
                $acc= $1;
                $db = ($i++ % 2 ) ? 'GenPept' : 'GenBank';
            } elsif( $id =~ /pdb\s+accession\s+(\S+)/ ) {
                $acc= $1;
                $db = 'PDB';
            } else {
                $acc= $id;
                $db = '';
            }
            $annotation->add_Annotation
                ('dblink',
                 Bio::Annotation::DBLink->new
                 (-primary_id => $acc,
                  -database => $db,
                  -tagname => 'dblink'));
            }
        } else {
            $self->warn("Cannot match $dbsource\n");
        }
        if( $dbsource =~ s/xrefs\s+\(non\-sequence\s+databases\):\s+
            ((?:\S+,\s+)+\S+)//x ) {
            for my $id ( split(/\,\s+/,$1) ) {
                my $db;
                # this is because GenBank dropped the spaces!!!
                # I'm sure we're not going to get this right
                ##if( $id =~ s/^://i ) {
                ##    $db = $1;
                ##}
                $db = substr($id,0,index($id,':'));
                if (! exists $DBSOURCE{ $db }) {
                    $db = '';   # do we want 'GenBank' here?
                }
                $id = substr($id,index($id,':')+1);
                $annotation->add_Annotation
                    ('dblink',Bio::Annotation::DBLink->new
                     (-primary_id => $id,
                      -database => $db,
                      -tagname => 'dblink'));
            }
        }
    } else {
        if( $dbsource =~ /^(\S*?):?\s*accession\s+(\S+)\.(\d+)/ ) {
            my ($db,$id,$version) = ($1,$2,$3);
            $annotation->add_Annotation
            ('dblink',
             Bio::Annotation::DBLink->new
             (-primary_id => $id,
              -version => $version,
              -database => $db || 'GenBank',
              -tagname => 'dblink'));
        } elsif ( $dbsource =~ /(\S+)([\.:])(\d+)/ ) {
            my ($id, $db, $version);
            if ($2 eq ':') {
                ($db, $id) = ($1, $3);
            } else {
                ($db, $id, $version) = ('GenBank', $1, $3);
            }
            $annotation->add_Annotation('dblink',
                Bio::Annotation::DBLink->new(
                    -primary_id => $id,
                    -version => $version,
                    -database => $db,
                    -tagname => 'dblink')
                );
        } else {
            $self->warn("Unrecognized DBSOURCE data: $dbsource\n");
        }
    }
}

# EMBL DR lines
# UniProt/SwissProt DR lines
sub _generic_dbsource {
    my ($self, $data) = @_;
    #$self->debug(Dumper($data));
    while ($data->{DATA} =~ m{([^\n]+)}og) { 
        my $dblink = $1;
        $dblink =~ s{\.$}{};
        my $link;
        my @linkdata = split '; ',$dblink;
        if ( $dblink =~ m{([^\s;]+);\s*([^\s;]+);?\s*([^\s;]+)?}) {
        #if ( $dblink =~ m{([^\s;]+);\s*([^\s;]+);?\s*([^\s;]+)?}) {
            my ($databse, $prim_id, $sec_id) = ($1,$2,$3);
            $link = Bio::Annotation::DBLink->new(-database    => $databse,
                                -primary_id  => $prim_id,
                                -optional_id => $sec_id);
        } else {
            $self->warn("No match for $dblink");
        }
        $self->annotation_collection->add_Annotation('dblink', $link);        
    }
}


# GenBank REFERENCE and related lines
# EMBL R* lines
# UniProt/SwissProt R* lines
sub _generic_reference {
    my ($self, $data) = @_;
    my $seqformat = $self->format;
    my ($start, $end);
    # get these in EMBL/Swiss
    if ($data->{CROSSREF}) {
        while ($data->{CROSSREF} =~ m{(pubmed|doi|medline)(?:=|;\s+)(\S+)}oig) {
            my ($db, $ref) = (uc $1, $2);
            $ref =~ s{[;.]+$}{};
            $data->{$db} = $ref;
        }
    }
    # run some cleanup for swissprot
    if ($seqformat eq 'swiss') {
        for my $val (values %{ $data }) {
            $val =~ s{;$}{};
            $val =~ s{(\w-)\s}{$1};
        }
    }
    if ( $data->{POSITION} ) {
        if ($seqformat eq 'embl') {
            ($start, $end) = split '-', $data->{POSITION},2;
        } elsif ($data->{POSITION} =~ m{.+? OF (\d+)-(\d+).*}) { #swiss
            ($start, $end) = ($1, $2);
        }
    }
    if ($data->{DATA} =~ m{^\d+\s+\([a-z]+\s+(\d+)\s+to\s+(\d+)\)}xmso) {
        ($start, $end) = ($1, $2);
    } 
    my $ref = Bio::Annotation::Reference->new(
                    -comment    => $data->{REMARK},
                    -location   => $data->{JOURNAL},
                    -pubmed     => $data->{PUBMED},
                    -consortium => $data->{CONSRTM},
                    -title      => $data->{TITLE},
                    -authors    => $data->{AUTHORS},
                    -medline    => $data->{MEDLINE},
                    -doi        => $data->{DOI},
                    -rp         => $data->{POSITION}, # JIC...
                    -start      => $start,
                    -end        => $end,
                    );
    if ($data->{DATA} =~  m{^\d+\s+\((.*)\)}xmso) {
	      $ref->gb_reference($1);
	}
    $self->annotation_collection->add_Annotation('reference', $ref);
}

# GenBank COMMENT lines
# EMBL CC lines
# UniProt/SwissProt CC lines
sub _generic_comment {
    my ($self, $data) = @_;
    $self->annotation_collection->add_Annotation('comment',
        Bio::Annotation::Comment->new( -text => $data->{DATA} ));
}

####################### SEQFEATURE HANDLER #######################

# GenBank Feature Table
sub _generic_seqfeatures {
    my ($self, $data) = @_;
    return if $data->{FEATURE_KEY} eq 'FEATURES';
    my $primary_tag = $data->{FEATURE_KEY};
    
    # grab the NCBI taxon ID from the source SF
    if ($primary_tag eq 'source' && exists $data->{'db_xref'}) {
        if ( $self->{'_params'}->{'-species'} &&
            $data->{'db_xref'} =~ m{taxon:(\d+)}xmso ) {
            $self->{'_params'}->{'-species'}->ncbi_taxid($1);
        }
    }
    my $source = $self->format;
    
    my $seqid = ${ $self->get_params('accession_number')  }{'accession_number'};
    
    my $loc;
    eval {
        $loc = $self->{'_locfactory'}->from_string($data->{'LOCATION'});
    };
    if(! $loc) {
        $self->warn("exception while parsing location line [" .
                    $data->{'LOCATION'} .
                    "] in reading $source, ignoring feature " .
                    $data->{'primary_tag'}.
                    " (seqid=" . $seqid . "): " . $@);
        return;
    }
    if($seqid && (! $loc->is_remote())) {
        $loc->seq_id($seqid); # propagates if it is a split location
    }
    my $sf = Bio::SeqFeature::Generic->direct_new();
    $sf->location($loc);
    $sf->primary_tag($primary_tag);
    $sf->seq_id($seqid);
    $sf->source_tag($source);
    delete $data->{'FEATURE_KEY'};
    delete $data->{'LOCATION'};
    delete $data->{'NAME'};
    delete $data->{'DATA'};
    $sf->set_attributes(-tag => $data);
    push @{ $self->{'_params'}->{'-features'} }, $sf;
}

####################### ODDS AND ENDS #######################

# Those things that don't fit anywhere else.  If a specific name 
# maps to the below table, that class and method are used, otherwise
# it goes into a SimpleValue (I think this is a good argument for why
# we need a generic mechanism for storing annotation)

sub _generic_simplevalue {
    my ($self, $data) = @_;
    $self->annotation_collection->add_Annotation(
        Bio::Annotation::SimpleValue->new(-tagname => lc($data->{NAME}),
       -value => $data->{DATA})
        );
}

sub noop {}

sub _debug {
    my ($self, $data) = @_;
    $self->debug(Dumper($data));
}


1;
