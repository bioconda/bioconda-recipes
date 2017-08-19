#
# BioPerl module for interpro
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::interpro - InterProScan XML input/output stream 

=head1 SYNOPSIS

  # do not call this module directly, use Bio::SeqIO

  use strict;
  use Bio::SeqIO;

  my $io = Bio::SeqIO->new(-format => "interpro",
                           -file   => $interpro_file);

  while (my $seq = $io->next_seq) {
    # use the Sequence object
  }

=head1 DESCRIPTION

L<Bio::SeqIO::interpro> will parse Interpro scan XML (version 1.2) and
create L<Bio::SeqFeature::Generic> objects based on the contents of the
XML document.

L<Bio::SeqIO::interpro> will also attach the annotation given in the XML
file to the L<Bio::SeqFeature::Generic> objects that it creates.

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

=head1 AUTHOR - Jared Fox

Email jaredfox@ucla.edu

=head1 CONTRIBUTORS

Allen Day allenday@ucla.edu

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::interpro;
use strict;
use Bio::SeqFeature::Generic;
use XML::DOM;
use XML::DOM::XPath;
use Bio::Seq::SeqFactory;
use Bio::Annotation::Collection;
use Bio::Annotation::DBLink;
use base qw(Bio::SeqIO);

my $idcounter = {};  # Used to generate unique id values
my $nvtoken = ": ";  # The token used if a name/value pair has to be stuffed
                     # into a single line

=head2 next_seq

 Title   : next_seq
 Usage   : my $seqobj = $stream->next_seq
 Function: Retrieves the next sequence from a SeqIO::interpro stream.
 Returns : A Bio::Seq::RichSeq object
 Args    : 

=cut

sub next_seq {
	my $self = shift;
	my ($desc);
	my $bioSeq = $self->_sequence_factory->create(-verbose =>$self->verbose());

	my $zinc = "(\"zincins\")";
	my $wing = "\"Winged helix\"";
	my $finger = "\"zinc finger\"";

	my $xml_fragment = undef;
	while(my $line = $self->_readline()){

		my $where = index($line, $zinc);
		my $wherefinger = index($line, $finger);
		my $finishedline = $line;
		my $wingwhere = index($line, $wing);

		# the interpro XML is not fully formed, so we need to convert the 
		# extra double quotes and ampersands into appropriate XML chracter codes
		if($where > 0){
			my @linearray = split /$zinc/, $line;
			$finishedline = join "&quot;zincins&quot;", $linearray[0], $linearray[2];
		}
		if(index($line, "&") > 0){
			my @linearray = split /&/, $line;
			$finishedline = join "&amp;", $linearray[0], $linearray[1];
		}
		if($wingwhere > 0){
			my @linearray = split /$wing/, $line;
			$finishedline = join "&quot;Winged helix&quot;", $linearray[0], $linearray[1];
		}

		$xml_fragment .= $finishedline;
		last if $finishedline =~ m!</protein>!;
	}
	# Match <protein> but not other similar elements like <protein-matches>
	return unless $xml_fragment =~ /<protein[\s>]/;

	$self->_parse_xml($xml_fragment);

	my $dom = $self->_dom;

	my ($protein_node) = $dom->findnodes('/protein');
	my @interproNodes = $protein_node->findnodes('/protein/interpro');
	my @DBNodes = $protein_node->findnodes('/protein/interpro/match');
	for(my $interpn=0; $interpn<scalar(@interproNodes); $interpn++){
		my $ipnlevel = join "", "/protein/interpro[", $interpn + 1, "]";
		my @matchNodes = $protein_node->findnodes($ipnlevel);
		for(my $match=0; $match<scalar(@matchNodes); $match++){
			my $matlevel = join "", "/protein/interpro[", $interpn+1, "]/match[", 
			  $match+1, "]/location";
			my @locNodes = $protein_node->findnodes($matlevel);
                        my $class_level = join "", "/protein/interpro[",$interpn+1, "]/classification";
                        my @goNodes = $protein_node->findnodes($class_level);
			my @seqFeatures = map { Bio::SeqFeature::Generic->new(
                  -start => $_->getAttribute('start'), 
						-end => $_->getAttribute('end'), 
                  -score => $_->getAttribute('score'), 
                  -source_tag => 'IPRscan',
                  -primary_tag => 'region',
                  -display_name => $interproNodes[$interpn]->getAttribute('name'),
                  -seq_id => $protein_node->getAttribute('id') ),
					} @locNodes;
			foreach my $seqFeature (@seqFeatures){
				$bioSeq->add_SeqFeature($seqFeature);

				my $annotation1 = Bio::Annotation::DBLink->new;
				$annotation1->database($matchNodes[$match]->getAttribute('dbname'));
				$annotation1->primary_id($matchNodes[$match]->getAttribute('id'));
				$annotation1->comment($matchNodes[$match]->getAttribute('name'));
				$seqFeature->annotation->add_Annotation('dblink',$annotation1);
				
				my $annotation2 = Bio::Annotation::DBLink->new;
				$annotation2->database('INTERPRO');
				$annotation2->primary_id($interproNodes[$interpn]->getAttribute('id'));
				$annotation2->comment($interproNodes[$interpn]->getAttribute('name'));
				$seqFeature->annotation->add_Annotation('dblink',$annotation2);

				# Bug 1908 (enhancement)
 				my $annotation3  = Bio::Annotation::DBLink->new;
  				$annotation3->database($DBNodes[$interpn]->getAttribute('dbname'));
  				$annotation3->primary_id($DBNodes[$interpn]->getAttribute('id'));
  				$annotation3->comment($DBNodes[$interpn]->getAttribute('name'));
  				$seqFeature->annotation->add_Annotation('dblink',$annotation3);
                                # need to put in the go annotation here!
                                 foreach my $g (@goNodes)
                                 {
                                     my $goid = $g->getAttribute('id');
                                     my $go_annotation = Bio::Annotation::DBLink->new;
                                     $go_annotation->database('GO');
                                     $go_annotation->primary_id($goid);
                                     $go_annotation->comment($goid);
                                     $seqFeature->annotation->add_Annotation('dblink', $go_annotation);
                                 }
			}
		}
	}
	my $accession = $protein_node->getAttribute('id');
	my $displayname = $protein_node->getAttribute('name');
	$bioSeq->accession($accession);
	$bioSeq->display_name($displayname);
	return $bioSeq;
}

=head2 _initialize

 Title   : _initialize
 Usage   : 
 Function: 
 Returns :
 Args    :

=cut

sub _initialize {
  my($self,@args) = @_;

  $self->SUPER::_initialize(@args);
  # hash for functions for decoding keys.
  $self->{'_func_ftunit_hash'} = {}; 

  my %param = @args;  # From SeqIO.pm
  @param{ map { lc $_ } keys %param } = values %param; # lowercase keys

  my $line = undef;
  # fast forward to first <protein/> record.
  while($line = $self->_readline()){
    # Match <protein> but not other similar elements like <protein-matches>
    if($line =~ /<protein[\s>]/){
      $self->_pushback($line);
      last;
    }
  }

  $self->_xml_parser( XML::DOM::Parser->new() );

  $self->_sequence_factory( Bio::Seq::SeqFactory->new
                           ( -verbose => $self->verbose(),
                             -type => 'Bio::Seq::RichSeq'))
    if ( ! defined $self->sequence_factory );
}

=head2 _sequence_factory

 Title   : _sequence_factory
 Usage   : 
 Function: 
 Returns :
 Args    :

=cut

sub _sequence_factory {
  my $self = shift;
  my $val = shift;

  $self->{'sequence_factory'} = $val if defined($val);
  return $self->{'sequence_factory'};
}

=head2 _xml_parser

 Title   : _xml_parser
 Usage   : 
 Function: 
 Returns :
 Args    :

=cut

sub _xml_parser {
  my $self = shift;
  my $val = shift;

  $self->{'xml_parser'} = $val if defined($val);
  return $self->{'xml_parser'};
}

=head2 _parse_xml

 Title   : _parse_xml
 Usage   : 
 Function: 
 Returns :
 Args    :

=cut

sub _parse_xml {
  my ($self,$xml) = @_;
  $self->_dom( $self->_xml_parser->parse($xml) );
  return 1;
}

=head2 _dom

 Title   : _dom
 Usage   : 
 Function: 
 Returns :
 Args    :

=cut

sub _dom {
  my $self = shift;
  my $val = shift;

  $self->{'dom'} = $val if defined($val);
  return $self->{'dom'};
}

1;

__END__
