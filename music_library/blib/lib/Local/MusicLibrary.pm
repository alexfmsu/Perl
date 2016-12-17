package MusicLibrary;

use 5.16.0;
use strict;
use warnings;
use utf8;

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

use Local::MusicLibraryReader;
use Local::MusicLibraryFilters;
use Local::MusicLibraryPrinter;

sub print_library{
	(my $_titles, my $_args) = (shift, shift);
	
	my $tb = MusicLibraryReader::read_library($_titles);

	(my $select_titles, my $select) = MusicLibraryFilters::apply_filters($_titles, $tb, $_args);

	$select = MusicLibraryFilters::sort_library($_titles, $select);

	MusicLibraryPrinter::print_library($_titles, $select_titles, $select);	
}

1;
