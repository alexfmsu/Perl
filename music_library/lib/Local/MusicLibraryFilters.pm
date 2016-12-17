package MusicLibraryFilters;

use 5.16.0;
use strict;
use warnings;
use utf8;

use Getopt::Long;
use List::MoreUtils qw{any};

# -------------------------------------------------------------------------------------------------
our $band;
our $year;
our $album;
our $track;
our $format;

our $sort;
our $columns;

GetOptions(
	"band:s" => \$band,
	"year:i" => \$year,
	"album:s" => \$album,
	"track:s" => \$track,
	"format:s" => \$format,
	"sort:s" => \$sort,
	"columns:s" => \$columns
);

sub sort_num{
	(my $x, my $y) = (shift, shift);

	return $x <=> $y;
};

sub sort_str{
	(my $x, my $y) = (shift, shift);

	return $x cmp $y;
};

my %sort_foo = (
	'band' => \&sort_str,
	'year' => \&sort_num,
	'album' => \&sort_str,
	'track' => \&sort_str,
	'format' => \&sort_str,
	'sort' => \&sort_str,
	'columns' => \&sort_str
);
# -------------------------------------------------------------------------------------------------
	
sub apply_filters{
	(my $titles, my $tb, my $args) = (shift, shift, shift);

	my @select = ();
	my @select_titles = ();

	no strict 'refs';
	no warnings 'experimental';
	for my $i (@$args){
		die("Option --'".$i."' requires an argument\n") if(defined($$_) && $sort_foo{$i}($$i, ''));	
	}

	for(@$tb){
		my %row = %{$_};
	 	
	 	my $found = 1;

	 	for my $i(@$titles){
	 		$found = 0 if $$i && $sort_foo{$i}($$i, $row{$i});
	 	}

	 	next if(!$found);
		
		push @select, \%row; 
	}
	
	use strict;

	if(!defined($columns)){
		@select_titles = @$titles;
	}else{
		my @cols = split(/,/, $columns);
		
		for my $c(@cols){
			die "field '".$_."' does not exist" if(!(any{$_ eq $c} @$titles));
			
			push @select_titles, $c;
		}
	}

	return (\@select_titles, \@select);
}

sub sort_library{
	(my $_titles, my $_select) = (shift, shift);

	my @titles = @$_titles;
	my @select = @$_select;

	if($sort && any{$_ eq $sort} @titles){
		@select = sort{ $sort_foo{$sort} ($a->{$sort}, $b->{$sort}) } @select;
	}

	return \@select;
}

1;