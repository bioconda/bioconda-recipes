# BioPerl module for Bio::SeqIO::entrezgene
#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::entrezgene - Entrez Gene ASN1 parser

=head1 SYNOPSIS

   use Bio::SeqIO;

   # don't instantiate directly - instead do
   my $seqio = Bio::SeqIO->new(-format => 'entrezgene',
                               -file => $file);
   my $gene = $seqio->next_seq;

=head1 DESCRIPTION

This is EntrezGene ASN bioperl parser. It is built on top of 
L<Bio::ASN1::EntrezGene>, a low level ASN parser built by Mingyi Liu 
(L<http://sourceforge.net/projects/egparser>). The easiest way to 
use it is shown above.

You will get most of the Entrez Gene annotation such as gene symbol, 
gene name and description, accession numbers associated 
with the gene, etc. Almost all of these are given as  L<Bio::AnnotationI> objects.

If you need all the data do:

   my $seqio = Bio::SeqIO->new(-format => 'entrezgene',
                               -file => $file,
                               -debug => 'on' );
   my ($gene,$genestructure,$uncaptured) = $seqio->next_seq;

The second variable returned, C<$genestructure>, is a L<Bio::Cluster::SequenceFamily>
object. It contains all Refseqs and the genomic contigs that are associated 
with the particular gene. The third variable, C<$uncaptured>, is a reference 
to a plain array.

You can also modify the output to allow back compatibility with the old 
LocusLink parser:

   my $seqio = Bio::SeqIO->new(-format => 'entrezgene',
                               -file => $file,
                               -locuslink => 'convert');

The C<-debug> and C<-locuslink> options slow down the parser.

Example code which looks for ontology terms:

  my $eio = new Bio::SeqIO(-file => $file,
                           -format => 'entrezgene',
                           -service_record => 'yes');

  while (my $seq = $eio->next_seq) {
    my $gid = $seq->accession_number;
    foreach my $ot ($ann->get_Annotations('OntologyTerm')) {
      next if ($ot->term->authority eq 'STS marker'); # No STS markers
      my $evid = $ot->comment;
      $evid =~ s/evidence: //i;
      my @ref = $ot->term->get_references;
      my $id = $ot->identifier;
      my $fid = 'GO:' . sprintf("%07u",$id);
      print join("\t",$gid, $ot->ontology->name, $ot->name, $evid,
        $fid, @ref?$ref[0]->medline:''), "\n";
    }
  }

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

=head1 AUTHOR - Stefan Kirov

Email skirov at utk.edu

=head1 CONTRIBUTORS

Hilmar Lapp, hlapp at gmx.net

=head1 APPENDIX

This parser is based on Bio::ASN1::EntrezGene module.

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

package Bio::SeqIO::entrezgene;

use strict;
use Bio::ASN1::EntrezGene;
use Bio::Seq;
use Bio::Species;
use Bio::Annotation::SimpleValue;
use Bio::Annotation::DBLink;
use Bio::Annotation::Comment;
use Bio::SeqFeature::Generic;
use Bio::Annotation::Reference;
use Bio::SeqFeature::Gene::Exon;
use Bio::SeqFeature::Gene::Transcript;
use Bio::SeqFeature::Gene::GeneStructure;
use Bio::Cluster::SequenceFamily;

#use Bio::Ontology::Ontology; Relationships.... later
use Bio::Ontology::Term;
use Bio::Annotation::OntologyTerm;
use Data::Dumper;
use base qw(Bio::SeqIO);

%main::eg_to_ll = (
    'Official Full Name' => 'OFFICIAL_GENE_NAME',
    'chromosome'         => 'CHR',
    'cyto'               => 'MAP',
    'Official Symbol'    => 'OFFICIAL_SYMBOL'
);
@main::egonly = keys %main::eg_to_ll;

# We define $xval and some other variables so we don't have
# to pass them as arguments
my ( $seq, $ann, $xval, %seqcollection, $buf );

sub _initialize {
    my ( $self, @args ) = @_;
    $self->SUPER::_initialize(@args);
    my %param = @args;
    @param{ map { lc $_ } keys %param } = values %param;    # lowercase keys
    $self->{_debug}          = $param{-debug}          || 'off';
    $self->{_locuslink}      = $param{-locuslink}      || 'no';
    $self->{_service_record} = $param{-service_record} || 'no';
    $self->{_parser} = Bio::ASN1::EntrezGene->new( file => $param{-file} );

    #Instantiate the low level parser here (it is -file in Bioperl
    #-should tell M.)
    #$self->{_parser}->next_seq; #First empty record- bug in Bio::ASN::Parser
}

sub next_seq {
    my $self  = shift;
    my $value = $self->{_parser}->next_seq(1);

    # $value contains data structure for the
    # record being parsed. 2 indicates the recommended
    # trimming mode of the data structure
    #I use 1 as I prefer not to descend into size 0 arrays
    return unless ($value);
    my $debug = $self->{_debug};
    $self->{_ann}        = Bio::Annotation::Collection->new();
    $self->{_currentann} = Bio::Annotation::Collection->new();
    my @alluncaptured;

    # parse the entry
    #my @keys=keys %{$value}; obsolete
    $xval = $value->[0];

	#return unless ($xval->{gene}->{desc} eq 'albumin');
	#return new Bio::Seq (-id=>'Generif service record', -seq=>'')
	#    unless ($xval->{'track-info'}{geneid}== 283);
    return Bio::Seq->new( -id => 'Generif service record', -seq => '' )
      if (
        ( $self->{_service_record} ne 'yes' )
        && ( $xval->{gene}->{desc} =~
            /record to support submission of generifs for a gene not in entrez/i
        )
      );

    #Basic data
    #$xval->{summary}=~s/\n//g;
    my $seq = Bio::Seq->new(
        -display_id       => $xval->{gene}{locus},
        -accession_number => $xval->{'track-info'}{geneid},
        -desc             => $xval->{summary}
    );

    #Source data here
    $self->_add_to_ann( $xval->{'track-info'}->{status}, 'Entrez Gene Status' );
    my $lineage = $xval->{source}{org}{orgname}{lineage};
    $lineage =~ s/[\s\n]//g;
    my ( $comp, @lineage );
    while ($lineage) {
        ( $comp, $lineage ) = split( /;/, $lineage, 2 );
        unshift @lineage, $comp;
    }
    unless ( exists( $xval->{source}{org}{orgname}{name}{binomial} ) ) {
        shift @lineage;
        my ( $gen, $sp ) = split( /\s/, $xval->{source}{org}{taxname} );
        if ( ($sp) && ( $sp ne '' ) ) {
            if ( $gen =~ /plasmid/i ) {
                $sp = $gen . $sp;
            }
            unshift @lineage, $sp;
        }
        else {
            unshift @lineage, 'unknown';
        }
    }
    else {
        my $sp = $xval->{source}{org}{orgname}{name}{binomial}{species};
        if ( ($sp) && ( $sp ne '' ) ) {
            my ( $spc, $strain ) = split( 'sp.', $sp );    #Do we need strain?
            $spc =~ s/\s//g;
            if ( ($spc) && ( $spc ne '' ) ) {
                unshift @lineage, $spc;
            }
            else {
                unshift @lineage, 'unknown';
            }
        }
        else {
            unshift @lineage, 'unknown';
        }
    }

    #print Dumper($xval->{source}{org});
    my $ncbiid;
    if ( ref( $xval->{source}{org}{db} ) eq 'ARRAY' ) {
        foreach my $taxonomy ( @{ $xval->{source}{org}{db} } ) {
            if ( lc( $taxonomy->{db} ) eq 'taxon' ) {
                $ncbiid = $taxonomy->{tag}{id};
            }
            else {
                push @alluncaptured, $taxonomy;
            }
            delete $xval->{source}{org}{db};
        }
    }
    $ncbiid = $ncbiid || $xval->{source}{org}{db}{tag}{id};
    my $s1     = shift @lineage;
    my $s2     = shift @lineage;
    my $specie = Bio::Species->new(
        -classification => [ $s1, $s2 ],
        -ncbi_taxid     => $ncbiid
    );
    $specie->common_name( $xval->{source}{org}{common} );
    if ( exists( $xval->{source}->{subtype} )
        && ( $xval->{source}->{subtype} ) )
    {
        if ( ref( $xval->{source}->{subtype} ) eq 'ARRAY' ) {
            foreach my $subtype ( @{ $xval->{source}->{subtype} } ) {
                $self->_add_to_ann( $subtype->{name}, $subtype->{subtype} );
            }
        }
        else {
            $self->_add_to_ann(
                $xval->{source}->{subtype}->{name},
                $xval->{source}->{subtype}->{subtype}
            );
        }
    }

    #Synonyms
    if ( ref( $xval->{gene}->{syn} ) eq 'ARRAY' ) {
        foreach my $symsyn ( @{ $xval->{gene}->{syn} } ) {
            $self->_add_to_ann( $symsyn, 'ALIAS_SYMBOL' );
        }
    }
    else {
        $self->_add_to_ann( $xval->{gene}->{syn}, 'ALIAS_SYMBOL' )
          if ( $xval->{gene}->{syn} );
    }

    #COMMENTS (STS not dealt with yet)
    if ( exists( $xval->{comments} ) ) {
        if ( ref( $xval->{comments} ) eq 'ARRAY' ) {
            for my $i ( 0 .. $#{ $xval->{comments} } ) {
                $self->{_current} = $xval->{comments}->[$i];
                push @alluncaptured, $self->_process_all_comments();
            }
        }
        else {
            $self->{_current} = $xval->{comments};
            push @alluncaptured, $self->_process_all_comments();
        }
    }

    #Gene
    if ( exists( $xval->{gene}->{db} ) ) {
        if ( ref( $xval->{gene}->{db} ) eq 'ARRAY' ) {
            foreach my $genedb ( @{ $xval->{gene}->{db} } ) {
                my $id =
                  exists( $genedb->{tag}->{id} )
                  ? $genedb->{tag}->{id}
                  : $genedb->{tag}->{str};
                $self->_add_to_ann( $id, $genedb->{db} );
            }
        }
        else {
            my $id =
              ( $xval->{gene}->{db}->{tag}->{id} )
              ? $xval->{gene}->{db}->{tag}->{id}
              : $xval->{gene}->{db}->{tag}->{str};
            $self->_add_to_ann( $id, $xval->{gene}->{db}->{db} );
        }
        $self->_add_to_ann( $xval->{gene}->{'locus-tag'}, 'LOCUS_SYNONYM' );
        delete $xval->{gene}->{db} unless ( $debug eq 'off' );
    }

    #LOCATION To do: uncaptured stuff
    if ( exists( $xval->{location} ) ) {
        if ( ref( $xval->{location} ) eq 'ARRAY' ) {
            foreach my $loc ( @{ $xval->{location} } ) {
                $self->_add_to_ann( $loc->{'display-str'},
                    $loc->{method}->{'map-type'} );
            }
        }
        else {
            $self->_add_to_ann(
                $xval->{location}->{'display-str'},
                $xval->{location}->{method}->{'map-type'}
            );
        }
        delete $xval->{location} unless ( $debug eq 'off' );
    }

    #LOCUS
    if ( ref( $xval->{locus} ) eq 'ARRAY' ) {
        foreach my $locus ( @{ $xval->{locus} } ) {
            $self->{_current} = $locus;
            push @alluncaptured, $self->_process_locus();
        }
    }
    else {
        push @alluncaptured, $self->_process_locus( $xval->{locus} );
    }

    #Homology
    my @homologies; # Sometimes there are multiple entries
    if (ref $xval->{homology} eq 'ARRAY') {
        @homologies = @{ $xval->{homology} };
    }
    else {
        push @homologies, $xval->{homology};
    }

    foreach my $homology (@homologies) {
        my ( $uncapt, $hom, $anchor ) = _process_src( $homology->{source} );
        foreach my $homann (@$hom) {
            $self->{_ann}->add_Annotation( 'dblink', $homann );
        }
        push @alluncaptured, $uncapt;
    }

    #Index terms
    if (   ( exists( $xval->{'xtra-index-terms'} ) )
        && ( $xval->{'xtra-index-terms'} ) )
    {
        if ( ref( $xval->{'xtra-index-terms'} ) eq 'ARRAY' ) {
            foreach my $term ( @{ $xval->{'xtra-index-terms'} } ) {
                $self->_add_to_ann( $term, 'Index terms' );
            }
        }
        else {
            $self->_add_to_ann( $xval->{'xtra-index-terms'}, 'Index terms' );
        }
    }

    #PROPERTIES
    my @prop;
    if ( exists( $xval->{properties} ) ) {
        if ( ref( $xval->{properties} ) eq 'ARRAY' ) {
            foreach my $property ( @{ $xval->{properties} } ) {
                push @alluncaptured, $self->_process_prop($property);
            }
        }
        else {
            push @alluncaptured, $self->_process_prop( $xval->{properties} );
        }
    }
    $seq->annotation( $self->{_ann} );
    $seq->species($specie);
    my @seqs;
    foreach my $key ( keys %seqcollection )
    {    #Optimize this, no need to go through hash?
        push @seqs, @{ $seqcollection{$key} };
    }
    my $cluster = Bio::Cluster::SequenceFamily->new(
        -family_id   => $seq->accession_number,
        -description => "Entrez Gene " . $seq->accession_number,
        -members     => \@seqs
    );    #Our EntrezGene object
          #clean
    unless ( $debug eq 'off' ) {
        delete $xval->{homology}->{source};
        delete( $xval->{summary} );
        delete( $xval->{'track-info'} );
        delete( $xval->{gene}{locus} );
        delete( $xval->{source}{org}{orgname}{lineage} );
        delete $xval->{source}{org}{orgname}{name}{binomial}{species};
        delete $xval->{gene}{syn};
        delete $xval->{source}->{subtype};
        delete $xval->{comments};
        delete $xval->{properties};
        delete $xval->{'xtra-index-terms'};
        delete $xval->{status};
    }
    push @alluncaptured, $xval;
    undef %seqcollection;
    $seq->annotation( _backcomp_ll( $self->{_ann} ) )
      if ( $self->{_locuslink} eq 'convert' );    #Fix this!
    return
      wantarray
      ? ( $seq, $cluster, \@alluncaptured )
      : $seq;                                     #Hilmar's suggestion
}

sub _process_refseq {
    my $self     = shift;
    my $products = shift;
    my $ns       = shift;
    my $iter     = shift;
    $iter++;
    my $pid;
    my ( @uncaptured, @products );
    if ( ref($products) eq 'ARRAY' ) { @products = @{$products}; }
    else                             { push @products, $products; }

    foreach my $product (@products) {
        if ( ( ref($product) eq 'ARRAY' ) && ( $#{$product} > -1 ) ) {
            $self->_process_refseq( $product, $ns, $iter );
            next;
        }
        if (
            (
                exists( $product->{products} )
                && ( !exists( $product->{accession} ) )
            )
          )
        {
            $self->_process_refseq( $product->{products}, $ns );
            next;
        }

        #if ((exists($product->{products})&&($product->{products}))) {
        #	$self->_process_refseq($product->{products},$ns,$iter);
        #}
        if (   ( exists( $product->{seqs}->{whole}->{gi} ) )
            && ( ref( $product->{seqs}->{whole}->{gi} ) eq 'ARRAY' ) )
        {
            $product->{seqs}->{whole}->{gi} =
              $product->{seqs}->{whole}->{gi}->[0];
        }    #Lose some data
        if (   ( exists( $product->{seqs}->{whole}->{gi} ) )
            || ( exists( $product->{accession} ) ) )
        {    #Minimal data required
            my $cann = Bio::Annotation::Collection->new();
            $pid = $product->{accession};
            my $authority =
              exists( $product->{type} )
              ? $product->{type}
              : $product->{heading};
            my $nseq = Bio::Seq->new(
                -accession_number => $product->{seqs}->{whole}->{gi},
                -display_id       => $product->{accession},
                -authority        => $authority,
                -namespace        => $ns
            );
            if ( exists( $product->{source} ) && ( $product->{source} ) ) {
                if (   ( !defined( $nseq->authority ) )
                    && ( exists( $product->{source}->{src} ) )
                    && ( exists( $product->{source}->{src}->{db} ) ) )
                {
                    $nseq->authority( $product->{source}->{src}->{db} );
                }
                my ( $uncapt, $allann ) = _process_src( $product->{source} );
                push @uncaptured, $uncapt;
                delete $product->{source};
                foreach my $annotation ( @{$allann} ) {
                    $cann->add_Annotation( 'dblink', $annotation );
                }
            }

            delete $product->{seqs}->{whole}->{gi};
            delete $product->{accession};
            delete $product->{source};
            delete $product->{heading};
            my ( $uncapt, $ann, $cfeat ) =
              $self->_process_comments( $product->{comment} )
              if ( exists( $product->{comment} ) );
            push @uncaptured, $uncapt;
            foreach my $feat ( @{$cfeat} ) {
                $nseq->add_SeqFeature($feat);
            }
            if ( exists( $product->{products} ) && ( $product->{products} ) ) {
                my ( $uncapt, $prodid ) =
                  $self->_process_refseq( $product->{products} );
                push @uncaptured, $uncapt;
                my $simann = Bio::Annotation::SimpleValue->new(
                    -value   => $prodid,
                    -tagname => 'product'
                );
                $cann->add_Annotation($simann);
            }
            foreach my $key ( keys %$ann ) {
                foreach my $val ( @{ $ann->{$key} } ) {
                    $cann->add_Annotation( $key, $val );
                }
            }
            $nseq->annotation($cann);
            push @{ $seqcollection{seq} }, $nseq;
        }
    }
    undef @products;
    undef $products;

    #my $ti2=new Benchmark;
    # my $td= timediff($ti2, $ti1);
    #        print "\tITER $iter:",timestr($td),"\n";
    return \@uncaptured, $pid, $seqcollection{seq}, $iter;
}

sub _process_links {
    my $self  = shift;
    my $links = shift;
    my ( @annot, @uncapt );
    if ( ref($links) eq 'ARRAY' ) {
        foreach my $link (@$links) {
            my ( $uncapt, $annot ) = _process_src( $link->{source} )
              if ( exists( $link->{source} ) );
            push @uncapt, $uncapt;
            foreach my $annotation (@$annot) {
                $self->{_ann}->add_Annotation( 'dblink', $annotation );
            }
        }
    }
    else {
        my ( $uncapt, $annot ) = _process_src( $links->{source} )
          if ( exists( $links->{source} ) );
        push @uncapt, $uncapt;
        foreach my $annotation (@$annot) {
            $self->{_ann}->add_Annotation( 'dblink', $annotation );
        }
    }
    return @uncapt;
}

sub _add_to_ann {    #Highest level only
    my ( $self, $val, $tag ) = @_;

  #  $val=~s/\n//g;#Low level EG parser leaves this so we take care of them here
    unless ($tag) {
        $self->warn( "No tagname for value $val, tag $tag " . $seq->id . "\n" );
        return;
    }
    my $simann =
      Bio::Annotation::SimpleValue->new( -value => $val, -tagname => $tag );
    $self->{_ann}->add_Annotation($simann);
}

sub _process_comments {
    my $self = shift;
    my $prod = shift;
    my ( %cann, @feat, @uncaptured, @comments, @sfann );
    if ( ( ref($prod) eq 'HASH' ) && ( exists( $prod->{comment} ) ) ) {
        $prod = $prod->{comment};
    }
    if ( ref($prod) eq 'ARRAY' ) {
        @comments = @{$prod};
    }
    else {
        push @comments, $prod;
    }
    my $i = 0;
    for my $comm (@comments) {    # Each comments is a hash reference
        $self->throw("Comment not a hash reference")
          unless ref($comm) eq 'HASH';
        my ( $desc, $nfeat, $add, @ann, @comm );

# next unless (exists($comm->{comment}));#Should be more careful when calling _process_comment:To do
        my $heading = $comm->{heading} || 'description';
        if ( !exists( $comm->{comment} ) ) {
            if (   ( exists( $comm->{type} ) )
                && ( $comm->{type} )
                && ( $self->{_current_heading} ) )
            {
                $comm->{type} = $self->{_current_heading};
            }
            if (   ( exists( $comm->{source} ) )
                && ( exists( $comm->{type} ) )
                && ( exists( $comm->{text} ) )
                && ( $comm->{type} ne 'comment' ) )
            {
                my ( $uncapt, $annot, $anchor ) =
                  _process_src( $comm->{source} );
                my $cann = shift(@$annot);
                if ( defined $cann ) {
                    $cann->optional_id( $comm->{text} );
                    $cann->authority( $comm->{type} );
                    $cann->version( $comm->{version} );
                    push @sfann, $cann;
                }
            }
        }

        while (ref($comm) eq 'HASH'
            && ( exists( $comm->{comment} ) )
            && ( $comm->{comment} ) )
        {
            if ( ( exists( $comm->{source} ) ) && ( $comm->{source} ) ) {
                my ( $uncapt, $allann, $anchor ) =
                  _process_src( $comm->{source} );
                if ($allann) {
                    delete $comm->{source};
                    push @uncaptured, $uncapt;
                    foreach my $annotation ( @{$allann} ) {
                        if ( $annotation->{_anchor} ) {
                            $desc .= $annotation->{_anchor} . ' ';
                        }
                        $annotation->optional_id($heading);
                        push @sfann, $annotation;
                        push @{ $cann{'dblink'} }, $annotation;
                    }
                }
            }

            $comm = $comm->{comment};

            if ( ref($comm) eq 'ARRAY' ) {
                @comm = @{$comm};
            }
            else {
                push @comm, $comm if ($comm);
            }

            foreach my $ccomm (@comm) {
                next unless ($ccomm);
                if ( exists( $ccomm->{source} ) ) {
                    my ( $uncapt, $allann, $anchor ) =
                      _process_src( $ccomm->{source} );
                    if ($allann) {
                        @sfann = @{$allann};
                        delete $ccomm->{source};
                        push @uncaptured, $uncapt;
                    }
                }
                $ccomm = $ccomm->{comment}
                  if ( exists( $ccomm->{comment} ) );    #Alice in Wonderland???
                my @loc;
                if ($ccomm) {
                    if ( ref($ccomm) eq 'ARRAY' ) {
                        @loc = @{$ccomm};
                    }
                    else {
                        push @loc, $ccomm;
                    }
                }
                foreach my $loc (@loc) {
                    if (   ( exists( $loc->{text} ) )
                        && ( $loc->{text} =~ /Location/i ) )
                    {
                        my ( $l1, $rest ) = split( /-/, $loc->{text} );
                        $l1   =~ s/\D//g;
                        $rest =~ s/^\s//;
                        my ( $l2, $scorestr ) = split( /\s/, $rest, 2 );
                        my ( $scoresrc, $score ) = split( /:/, $scorestr );
                        $score =~ s/\D//g;
                        my ( %tags, $tag );
                        unless ($l1) {
                            next;
                        }
                        $nfeat = Bio::SeqFeature::Generic->new(
                            -start   => $l1,
                            -end     => $l2,
                            -strand  => $tags{strand},
                            -source  => $loc->{type},
                            -seq_id  => $desc,
                            -primary => $heading,
                            -score   => $score,
                            -tag     => { score_src => $scoresrc }
                        );
                        my $sfeatann = Bio::Annotation::Collection->new();
                        foreach my $sfann (@sfann) {
                            $sfeatann->add_Annotation( 'dblink', $sfann );
                        }
                        undef @sfann;
                        $nfeat->annotation($sfeatann)
                          ; #Thus the annotation will be available both in the seq and seqfeat?
                        push @feat, $nfeat;
                        delete $loc->{text};
                        delete $loc->{type};
                    }
                    elsif ( exists( $loc->{label} ) ) {
                        my $simann = Bio::Annotation::SimpleValue->new(
                            -value   => $loc->{text},
                            -tagname => $loc->{label}
                        );
                        delete $loc->{text};
                        delete $loc->{label};
                        push @{ $cann{'simple'} }, $simann;
                        push @uncaptured, $loc;
                    }
                    elsif ( exists( $loc->{text} ) ) {
                        my $simann = Bio::Annotation::SimpleValue->new(
                            -value   => $loc->{text},
                            -tagname => $heading
                        );
                        delete $loc->{text};
                        push @{ $cann{'simple'} }, $simann;
                        push @uncaptured, $loc;
                    }
                }
            }    #Bit clumsy but that's what we get from the low level parser
        }
        $i++;
    }
    if (@sfann) {
        push @{ $cann{'dblink'} }, @sfann;
    }    #Annotation that is not location specific, for example phenotype
         #undef $self->{_current_heading};
    return \@uncaptured, \%cann, \@feat;
}

sub _process_src {
    my $src = shift;

    #Trick we do because sometimes we have an array ref
    my ( @ann, $anch, @uncapt );
    if ( ref($src) eq 'ARRAY' ) {
        foreach my $msrc (@$src) {
            my ( $uncapt, $ann, $anchor ) = _process_src($msrc);
            push @ann,    @$ann;
            push @uncapt, $uncapt;
            $anch = $anchor;
        }
        return \@uncapt, \@ann, $anch;
    }
    return unless ( exists( $src->{src}->{tag} ) );

    #my $t0=new Benchmark
    my $db = $src->{src}->{db};
    delete $src->{src}->{db};
    my $anchor = $src->{anchor} || '';
    delete $src->{anchor};
    my $url;
    if ( exists( $src->{url} ) && ( $src->{url} ) ) {
        $url = $src->{url};
        $url =~ s/\n//g;
        delete $src->{url};
    }
    if (   ( exists( $src->{src}->{tag}->{str} ) )
        && ( $src->{src}->{tag}->{str} ) )
    {
        my @sq = split( /[,;]/, $src->{src}->{tag}->{str} );
        delete $src->{src}->{tag};
        foreach my $id (@sq) {
            $id =~ s/\n//g;
            undef $anchor if ( $anchor eq 'id' );
            my $simann = Bio::Annotation::DBLink->new(
                -database   => $db,
                -primary_id => $id,
                -authority  => $src->{heading}
            );
            $simann->url($url) if ($url);    #DBLink should have URL!
            push @ann, $simann;
        }
    }
    else {
        my $id = $src->{src}->{tag}->{id} || '';
        delete $src->{src}->{tag};
        undef $anchor if ( $anchor eq 'id' );
        $id =~ s/\n//g;
        my $simann = Bio::Annotation::DBLink->new(
            -database   => $db,
            -primary_id => $id,
            -authority  => $src->{heading}
        );
        if ($anchor) {
            $simann->{_anchor} = $anchor;
            $simann->optional_id($anchor);
        }
        $simann->url($url) if ($url);    #DBLink should have URL!
        push @ann, $simann;
    }

    #my $t1=new Benchmark;
    #my $td= timediff($t1, $t0);
    #print "\t\tSRC:",timestr($td),"\n";
    return $src, \@ann, $anchor;
}

sub _add_references {
    my $self = shift;
    my $refs = shift;
    if ( ref($refs) eq 'ARRAY' ) {
        foreach my $ref (@$refs) {
            my $refan = Bio::Annotation::Reference->new(
                -database   => 'Pubmed',
                -primary_id => $ref
            );
            $self->{_ann}->add_Annotation( 'Reference', $refan );
        }
    }
    else {
        my $refan = Bio::Annotation::Reference->new(
            -database   => 'Pubmed',
            -primary_id => $refs
        );
        $self->{_ann}->add_Annotation( 'Reference', $refan );
    }
}

#Should we do this at all if no seq coord are present?
sub _process_locus {
    my $self = shift;
    my @uncapt;
    return $self
      unless ( exists( $self->{_current}->{accession} )
        && ( $self->{_current}->{accession} ) );
    my $gseq = Bio::Seq->new(
        -display_id       => $self->{_current}->{accession},
        -version          => $self->{_current}->{version},
        -accession_number => $self->{_current}->{seqs}->{'int'}->{id}->{gi},
        -authority        => $self->{_current}->{type},
        -namespace        => $self->{_current}->{heading}
    );
    delete $self->{_current}->{accession};
    delete $self->{_current}->{version};
    delete $self->{_current}->{'int'}->{id}->{gi};
    my ( $start, $end, $strand );

    if ( exists( $self->{_current}->{seqs}->{'int'}->{from} ) ) {
        $start = $self->{_current}->{seqs}->{'int'}->{from};
        delete $self->{_current}->{seqs}->{'int'}->{from};

      #unless ($start) {print $locus->{seqs}->{'int'}->{from},"\n",$locus,"\n";}
        $end = $self->{_current}->{seqs}->{'int'}->{to};
        delete $self->{_current}->{seqs}->{'int'}->{to};
        delete $self->{_current}->{seqs}->{'int'}->{strand};
        $strand =
          $self->{_current}->{seqs}->{'int'}->{strand} eq 'minus' ? -1 : 1
          if ( exists( $self->{_current}->{seqs}->{'int'}->{strand} ) )
          ;    #1 being default
        my $nfeat = Bio::SeqFeature::Generic->new(
            -start  => $start,
            -end    => $end,
            -strand => $strand,
            primary => 'gene location'
        );
        $gseq->add_SeqFeature($nfeat);
    }

    my @products;
    if ( ref( $self->{_current}->{products} ) eq 'ARRAY' ) {
        @products = @{ $self->{_current}->{products} };
    }
    else {
        push @products, $self->{_current}->{products};
    }
    delete $self->{_current}->{products};

    my $gstruct = Bio::SeqFeature::Gene::GeneStructure->new();
    foreach my $product (@products) {
        my ( $tr, $uncapt ) =
          _process_products_coordinates( $product, $start, $end, $strand );
        $gstruct->add_transcript($tr) if ($tr);
        undef $tr->{parent};    #Because of a cycleG
        push @uncapt, $uncapt;
    }
    $gseq->add_SeqFeature($gstruct);
    push @{ $seqcollection{genestructure} }, $gseq;
    return @uncapt;
}

=head1 _process_products_coordinates

To do:

=cut

sub _process_products_coordinates {
    my $coord = shift;
    my $start = shift
      || 0;    #In case it is not known: should there be an entry at all?
    my $end    = shift || 1;
    my $strand = shift || 1;
    return unless ( exists( $coord->{accession} ) );

    my ( @coords, @uncapt );
    my $transcript = Bio::SeqFeature::Gene::Transcript->new(
        -primary => $coord->{accession},    #Desc is actually non functional...
        -start   => $start,
        -end     => $end,
        -strand  => $strand,
        -desc    => $coord->{type}
    );

    if (   ( exists( $coord->{'genomic-coords'}->{mix}->{'int'} ) )
        || ( exists( $coord->{'genomic-coords'}->{'packed-int'} ) ) )
    {
        @coords =
          exists( $coord->{'genomic-coords'}->{mix}->{'int'} )
          ? @{ $coord->{'genomic-coords'}->{mix}->{'int'} }
          : @{ $coord->{'genomic-coords'}->{'packed-int'} };
        foreach my $exon (@coords) {
            next unless ( exists( $exon->{from} ) );
            my $exonobj = Bio::SeqFeature::Gene::Exon->new(
                -start  => $exon->{from},
                -end    => $exon->{to},
                -strand => $strand
            );
            $transcript->add_exon($exonobj);
            delete $exon->{from};
            delete $exon->{to};
            delete $exon->{strand};
            push @uncapt, $exon;
        }
    }

    my ( $prot, $uncapt );
    if ( exists( $coord->{products} ) ) {
        my @products; # Sometimes there are multiple entries
        if (ref $coord->{products} eq 'ARRAY') {
            @products = @{ $coord->{products} };
        }
        else {
            push @products, $coord->{products};
        }

        foreach my $product (@products) {
            my ( $prot, $uncapt ) =
              _process_products_coordinates( $product,
                $start, $end, $strand );
            $transcript->add_SeqFeature($prot);
            push @uncapt, $uncapt;
        }
    }
    return $transcript, \@uncapt;
}

=head1 _process_prop

To do: process GO

=cut

sub _process_prop {
    my $self = shift;
    my $prop = shift;
    my @uncapt;
    if ( exists( $prop->{properties} ) ) {    #Iterate
        if ( ref( $prop->{properties} ) eq 'ARRAY' ) {
            foreach my $propn ( @{ $prop->{properties} } ) {
                push @uncapt, $self->_process_prop($propn);
            }
        }
        else {
            push @uncapt, $self->_process_prop( $prop->{properties} );
        }
    }
    unless ( ( exists( $prop->{heading} ) )
        && ( $prop->{heading} eq 'GeneOntology' ) )
    {
        $self->_add_to_ann( $prop->{text}, $prop->{label} )
          if ( exists( $prop->{text} ) );
        delete $prop->{text};
        delete $prop->{label};
        push @uncapt, $prop;
        return \@uncapt;
    }

    #Will do GO later
    if ( exists( $prop->{comment} ) ) {
        push @uncapt, $self->_process_go( $prop->{comment} );
    }
}

sub _process_all_comments {
    my $self    = shift;
    my $product = $self->{_current};    #Better without copying
    my @alluncaptured;
    my $heading = $product->{heading} if ( exists( $product->{heading} ) );
    if ($heading) {

        #my $tx1=new Benchmark;
        delete $product->{heading};
      CLASS: {
            if ( $heading =~ 'RefSeq Status' )
            {    #IN case NCBI changes slightly the spacing:-)
                $self->_add_to_ann( $product->{label}, 'RefSeq status' );
                last CLASS;
            }
            if ( $heading =~ 'NCBI Reference Sequences' )
            {    #IN case NCBI changes slightly the spacing:-)
                if (   ( exists( $product->{comment} ) )
                    && ( !exists( $product->{products} ) ) )
                {
                    $product->{products} = $product->{comment};
                }

#unless (($product->{products})&&(exists($product->{comment}))) {
#if (ref ($product->{comment}) eq 'ARRAY') {
#	foreach my $pc (@{$product->{comment}}) {
#		push @{$product->{products}},$pc->{products};
#	}
#}
#else {
#	$product->{products}=exists($product->{comments}->{products})?$product->{comments}->{products}:$product->{comment};
#}
#}
                my @uncaptured =
                  $self->_process_refseq( $product->{products}, 'refseq' );
                push @alluncaptured, @uncaptured;
                last CLASS;
            }
            if (   ( $heading =~ 'Related Sequences' )
                && ( exists( $product->{products} ) ) )
            {    #IN case NCBI changes slightly the spacing:-)
                my @uncaptured = $self->_process_refseq( $product->{products} );
                push @alluncaptured, @uncaptured;
                last CLASS;
            }
            if (   ( $heading =~ 'Additional Links' )
                && ( exists( $product->{comment} ) ) )
            {    #IN case NCBI changes slightly the spacing:-)
                push @alluncaptured,
                  $self->_process_links( $product->{comment} );
                last CLASS;
            }
            if ( $heading =~ 'LocusTagLink' )
            {    #IN case NCBI changes slightly the spacing:-)
                $self->_add_to_ann(
                    $product->{source}->{src}->{tag}->{id},
                    $product->{source}->{src}->{db}
                );
                last CLASS;
            }
            if (   ( $heading =~ 'Sequence Tagged Sites' )
                && ( exists( $product->{comment} ) ) )
            {    #IN case NCBI changes slightly the spacing:-)
                push @alluncaptured, $self->_process_STS( $product->{comment} );
                delete $product->{comment};
                last CLASS;
            }
            if ( $heading =~ 'Pathways' ) {
                $self->{_current_heading} = 'Pathways';
                last CLASS;
            }
        }

        # my $tx2=new Benchmark;
        # my $td= timediff($tx2, $tx1);
        #print "\t\t$heading:",timestr($td),"\n";

    }
    if ( exists( $product->{type} ) && ( $product->{type} eq 'generif' ) ) {
        push @alluncaptured, $self->_process_grif($product);
        return @alluncaptured;    #Maybe still process the comments?
    }
    if ( exists( $product->{refs} ) ) {
        $self->_add_references( $product->{refs}->{pmid} );
        delete $product->{refs}->{pmid};
        push @alluncaptured, $product;
    }
    if ( exists( $product->{comment} ) ) {
        my ( $uncapt, $allan, $allfeat ) =
          $self->_process_comments( $product->{comment} );
        foreach my $key ( keys %$allan ) {
            foreach my $val ( @{ $allan->{$key} } ) {
                $self->{_ann}->add_Annotation( $key, $val );
            }
        }
        delete $product->{refs}->{comment};
        push @alluncaptured, $uncapt;
    }

    #if (exists($product->{source})) {
    #    my ($uncapt,$ann,$anchor)=_process_src($product->{source});
    #    foreach my $dbl (@$ann) {
    #        $self->{_ann}->add_Annotation('dblink',$dbl);
    #    }
    #}
    return @alluncaptured;
}

sub _process_STS {
    my $self    = shift;
    my $comment = shift;
    my @comm;
    push @comm, ( ref($comment) eq 'ARRAY' ) ? @{$comment} : $comment;
    foreach my $product (@comm) {
        my $sts = Bio::Ontology::Term->new(
            -identifier => $product->{source}->{src}->{tag}->{id},
            -name       => $product->{source}->{anchor},
            -comment    => $product->{source}->{'post-text'}
        );
        $sts->namespace( $product->{source}->{src}->{db} );
        $sts->authority('STS marker');
        my @alt;
        if ( exists( $product->{comment} ) ) {
            push @alt,
              ( ref( $product->{comment} ) eq 'ARRAY' )
              ? @{ $product->{comment} }
              : $product->{comment};
            foreach my $alt (@alt) {
                $sts->add_synonym( $alt->{text} );
            }
        }
        my $annterm = Bio::Annotation::OntologyTerm->new();
        $annterm->term($sts);
        $self->{_ann}->add_Annotation( 'OntologyTerm', $annterm );
    }
}

sub _process_go {
    my $self = shift;
    my $comm = shift;
    my @comm;
    push @comm, ( ref($comm) eq 'ARRAY' ) ? @{$comm} : $comm;
    foreach my $comp (@comm) {
        my $category = $comp->{label};
        if ( ref( $comp->{comment} ) eq 'ARRAY' ) {
            foreach my $go ( @{ $comp->{comment} } ) {
                my $term = _get_go_term( $go, $category );
                my $annterm = Bio::Annotation::OntologyTerm->new(
                    -tagname => 'Gene Ontology' );
                $annterm->term($term);
                $self->{_ann}->add_Annotation( 'OntologyTerm', $annterm );
            }
        }
        else {
            my $term = _get_go_term( $comp->{comment}, $category );
            my $annterm =
              Bio::Annotation::OntologyTerm->new( -tagname => 'Gene Ontology' );
            $annterm->term($term);
            $self->{_ann}->add_Annotation( 'OntologyTerm', $annterm );
        }
    }
}

sub _process_grif {
    my $self = shift;
    my $grif = shift;
    if (   ( exists( $grif->{comment} ) )
        && ( ref( $grif->{comment} ) eq 'ARRAY' ) )
    {
        my @uncapt;
        foreach my $product ( @{ $grif->{comment} } ) {
            next unless ( exists( $product->{text} ) );
            my $uproduct = $self->_process_grif($product);

            #$self->{_ann->add_Annotation($type,$grifobj);
            push @uncapt, $uproduct;
        }
        return \@uncapt;
    }
    if ( exists( $grif->{comment}->{comment} ) ) {
        $grif = $grif->{comment};
    }
    my $ref =
      ( ref( $grif->{refs} ) eq 'ARRAY' )
      ? shift @{ $grif->{refs} }
      : $grif->{refs};
    my $refergene = '';
    my $refdb     = '';
    my ( $obj, $type );
    if ( $ref->{pmid} ) {
        if ( exists( $grif->{source} ) )
        {    #unfortunatrely we cannot put yet everything in
            $refergene = $grif->{source}->{src}->{tag}->{id};
            $refdb     = $grif->{source}->{src}->{db};
        }
        my $grifobj = Bio::Annotation::Comment->new( -text => $grif->{text} );
        $obj = Bio::Annotation::DBLink->new(
            -database   => 'generif',
            -primary_id => $ref->{pmid}
            , #The pubmed id (at least the first one) which is a base for the conclusion
            -version     => $grif->{version},
            -optional_id => $refergene,
            -authority   => $refdb
        );
        $obj->comment($grifobj);
        $type = 'dblink';
    }
    else {
        $obj = Bio::Annotation::SimpleValue->new( $grif->{text}, 'generif' );
        $type = 'generif';
    }
    delete $grif->{text};
    delete $grif->{version};
    delete $grif->{type};
    delete $grif->{refs};
    $self->{_ann}->add_Annotation( $type, $obj );
    return $grif;
}

sub _get_go_term {
    my $go       = shift;
    my $category = shift;
    my $refan    = Bio::Annotation::Reference->new(    #We expect one ref per GO
        -medline => $go->{refs}->{pmid},
        -title   => 'no title'
    );
    my $term = Bio::Ontology::Term->new(
        -identifier => $go->{source}->{src}->{tag}->{id},
        -name       => $go->{source}->{anchor},
        -definition => $go->{source}->{anchor},
        -comment    => $go->{source}->{'post-text'},
        -version    => $go->{version}
    );
    $term->add_reference($refan);
    $term->namespace($category);
    return $term;
}

sub _backcomp_ll {
    my $ann    = shift;
    my $newann = Bio::Annotation::Collection->new();

    #$newann->{_annotation}->{ALIAS_SYMBOL}=$ann->{_annotation}->{ALIAS_SYMBOL};
    # $newann->{_annotation}->{CHR}=$ann->{_annotation}->{chromosome};
    # $newann->{_annotation}->{MAP}=$ann->{_annotation}->{cyto};
    foreach my $tagmap ( keys %{ $ann->{_typemap}->{_type} } ) {
        next if ( grep( /$tagmap/, @main::egonly ) );
        $newann->{_annotation}->{$tagmap} = $ann->{_annotation}->{$tagmap};
    }

#$newann->{_annotation}->{Reference}=$ann->{_annotation}->{Reference};
#$newann->{_annotation}->{generif}=$ann->{_annotation}->{generif};
#$newann->{_annotation}->{comment}=$ann->{_annotation}->{comment};
# $newann->{_annotation}->{OFFICIAL_GENE_NAME}=$ann->{_annotation}->{'Official Full Name'};
    $newann->{_typemap}->{_type} = $ann->{_typemap}->{_type};
    foreach my $ftype ( keys %main::eg_to_ll ) {
        my $newkey = $main::eg_to_ll{$ftype};
        $newann->{_annotation}->{$newkey} = $ann->{_annotation}->{$ftype};
        $newann->{_typemap}->{_type}->{$newkey} =
          'Bio::Annotation::SimpleValue';
        delete $newann->{_typemap}->{_type}->{$ftype};
        $newann->{_annotation}->{$newkey}->[0]->{tagname} = $newkey;
    }
    foreach my $dblink ( @{ $newann->{_annotation}->{dblink} } ) {
        next unless ( $dblink->{_url} );
        my $simann = Bio::Annotation::SimpleValue->new(
            -value   => $dblink->{_url},
            -tagname => 'URL'
        );
        $newann->add_Annotation($simann);
    }

#        my $simann=Bio::Annotation::SimpleValue->new(-value=>$seq->desc,-tagname=>'comment');
#        $newann->add_Annotation($simann);

    return $newann;
}

1;
