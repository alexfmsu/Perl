package MusicLibrary;

use 5.16.0;
use strict;
use warnings;
use utf8;

use Local::MusicLibraryReader;
use Local::MusicLibraryFilters;
use Local::MusicLibraryPrinter;

sub print_librar{
	(my $_titles, my $_args = shift, shift);
	
	my @titles = @$_titles;
	my @args = @$_args;

	my $tb = MusicLibraryReader::read_library(\@titles);

	(my $select_titles, my $select) = MusicLibraryFilters::apply_filters(\@titles, $tb, \@args);

	$select = MusicLibraryFilters::sort_library(\@titles, $select);

	MusicLibraryPrinter::print_library(\@titles, $select_titles, $select);	
}

1;
