#
# BioPerl module for Bio::SeqIO::excel
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Hilmar Lapp <hlapp at gmx.net>
#

#
# (c) Hilmar Lapp, hlapp at gmx.net, 2005.
# (c) GNF, Genomics Institute of the Novartis Research Foundation, 2005.
#
# You may distribute this module under the same terms as perl itself.
# Refer to the Perl Artistic License (see the license accompanying this
# software package, or see http://www.perl.com/language/misc/Artistic.html)
# for the terms under which you may use, modify, and redistribute this module.
#
# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::excel - sequence input/output stream from a
                    MSExcel-formatted table

=head1 SYNOPSIS

  #It is probably best not to use this object directly, but
  #rather go through the SeqIO handler system. Go:

  $stream = Bio::SeqIO->new(-file => $filename, -format => 'excel');

  while ( my $seq = $stream->next_seq() ) {
	# do something with $seq
  }

=head1 DESCRIPTION

This class transforms records in a MS Excel workbook file into
Bio::Seq objects. It is derived from the table format module and
merely defines additional properties and overrides the way to get data
from the file and advance to the next record.

The module permits specifying which columns hold which type of
annotation. The semantics of certain attributes, if present, are
pre-defined, e.g., accession number and sequence. Additional
attributes may be added to the annotation bundle. See
L<Bio::SeqIO::table> for a complete list of parameters and
capabilities.

You may also specify the worksheet from which to obtain the data, and
after finishing one worksheet you may change the name to keep reading
from another worksheet (in the same file).

This module depends on Spreadsheet::ParseExcel to parse the underlying
Excel file.

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
the bugs and their resolution.

Bug reports can be submitted via email or the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Hilmar Lapp

Email hlapp at gmx.net

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::excel;
use strict;

use Bio::SeqIO;
use Spreadsheet::ParseExcel;
#use Spreadsheet::ParseExcel::Workbook;

use base qw(Bio::SeqIO::table);

=head2 new

 Title   : new
 Usage   : $stream = Bio::SeqIO->new(-file => $filename, -format => 'excel')
 Function: Returns a new seqstream
 Returns : A Bio::SeqIO stream for a MS Excel format

 Args    : Supports the same named parameters as Bio::SeqIO::table,
           except -delim, which obviously does not apply to a binary
           format. In addition, the following parameters are supported.

             -worksheet the name of the worksheet holding the table;
                        if unspecified the first worksheet will be
                        used


=cut

sub _initialize {
    my($self,@args) = @_;

    # chained initialization
    $self->SUPER::_initialize(@args);

    # our own parameters
    my ($worksheet) = $self->_rearrange([qw(WORKSHEET)], @args);

    # store options and apply defaults
    $self->worksheet($worksheet || 0);

}

=head2 worksheet

 Title   : worksheet
 Usage   : $obj->worksheet($newval)
 Function: Get/set the name of the worksheet holding the table. The
           worksheet name may also be a numeric index.

           You may change the value during parsing at any time in
           order to start reading from a different worksheet (in the
           same file).

 Example :
 Returns : value of worksheet (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub worksheet{
    my $self = shift;

    if (@_) {
        my $sheetname = shift;
        # on set we reset the parser here in order to allow reading
        # from multiple worksheets in a row
        $self->_worksheet(undef) if defined($sheetname);
        return $self->{'worksheet'} = $sheetname;
    }
    return $self->{'worksheet'};
}

=head2 close

 Title   : close
 Usage   :
 Function: Close and/or release the resources used by this parser instance.

           We override this here in order to free up the worksheet and
           other related objects.

 Example :
 Returns :
 Args    :


=cut

sub close{
    my $self = shift;

    $self->_worksheet(undef);
    # make sure we chain to the inherited method
    $self->SUPER::close(@_);
}

=head1 Internal methods

All methods with a leading underscore are not meant to be part of the
'official' API. They are for use by this module only, consider them
private unless you are a developer trying to modify this module.

=cut

=head2 _worksheet

 Title   : _worksheet
 Usage   : $obj->_worksheet($newval)
 Function: Get/set the worksheet object to be used for accessing cells.
 Example :
 Returns : value of _worksheet (a Spreadsheet::ParseExcel::Worksheet object)
 Args    : on set, new value (a Spreadsheet::ParseExcel::Worksheet
           object or undef, optional)


=cut

sub _worksheet{
    my $self = shift;

    return $self->{'_worksheet'} = shift if @_;
    return $self->{'_worksheet'};
}

=head2 _next_record

 Title   : _next_record
 Usage   :
 Function: Navigates the underlying file to the next record.

           We override this here in order to adapt navigation to data
           in an Excel worksheet.

 Example :
 Returns : TRUE if the navigation was successful and FALSE
           otherwise. Unsuccessful navigation will usually be treated
           as an end-of-file condition.
 Args    :


=cut

sub _next_record{
    my $self = shift;

    my $wsheet = $self->_worksheet();
    if (! defined($wsheet)) {
        # worksheet hasn't been initialized yet, do so now
        my $wbook = Spreadsheet::ParseExcel::Workbook->Parse($self->_fh);
        $wsheet = $wbook->Worksheet($self->worksheet);
        # store the result
        $self->_worksheet($wsheet);
        # re-initialize the current row
        $self->{'_row'} = -1;
    }

    # we need a valid worksheet to continue
    return unless defined($wsheet);

    # check whether we are at or beyond the last defined row
    my ($minrow, $maxrow) = $wsheet->RowRange();
    return if $self->{'_row'} >= $maxrow;

    # we don't check for empty rows here as in order to do that we'd
    # have to know in which column to look
    # so, just advance to the next row
    $self->{'_row'}++;

    # done
    return 1;
}

=head2 _get_row_values

 Title   : _get_row_values
 Usage   :
 Function: Get the values for the current line (or row) as an array in
           the order of columns.

           We override this here in order to adapt access to column
           values to data contained in an Excel worksheet.

 Example :
 Returns : An array of column values for the current row.
 Args    :


=cut

sub _get_row_values{
    my $self = shift;

    # obtain the range of columns - we use all that are defined
    my $wsheet = $self->_worksheet();
    my ($colmin,$colmax) = $wsheet->ColRange();

    # build the array of columns for the current row
    my @cols = ();
    my $row = $self->{'_row'};
    for (my $i = $colmin; $i <= $colmax; $i++) {
        my $cell = $wsheet->Cell($row, $i);
        push(@cols, defined($cell) ? $cell->Value : $cell);
    }
    # done
    return @cols;
}

1;
