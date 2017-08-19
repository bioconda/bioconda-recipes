#
# BioPerl module for Bio::SeqIO::chaosxml
#
# Chris Mungall <cjm@fruitfly.org>
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::chaosxml - chaosxml sequence input/output stream

=head1 SYNOPSIS

    #In general you will not want to use this module directly;
    #use the chaosxml format via SeqIO

    $outstream = Bio::SeqIO->new(-file => $filename, -format => 'chaosxml');

    while ( my $seq = $instream->next_seq() ) {
       $outstream->write_seq($seq);
    }

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from chaos files.

B<CURRENTLY WRITE ONLY>

ChaosXML is an XML mapping of the chado relational database; for more
information, see http://www.fruitfly.org/chaos-xml

Chaos can have other syntaxes than XML (eg S-Expressions, Indented text)

See L<Bio::SeqIO::chaos> for a full description


=head1 VERY VERY IMPORTANT

!!!!!!!!!!!CHADO AND CHAOS USE INTERBASE COORDINATES!!!!!!!!!!!!!!!!

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
the bugs and their resolution.  Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Chris Mungall

Email cjm@fruitfly.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::chaosxml;
use strict;

use Data::Stag::XMLWriter;

use base qw(Bio::SeqIO::chaos);

sub default_handler_class {
    return Data::Stag->getformathandler('xml');
}

1;
