package MusicLibraryReader;

use 5.16.0;
use strict;
use warnings;
use utf8;

binmode(STDIN, ':utf8');

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub read_library{
	my $titles = shift;

	my @tb = ();

	while(<>){
		if(m{
			^
			\.
			/
			(?<band>[^/]+)
			/
			(?<year>\d+)
			\s+ - \s+
			(?<album>[^/]+)
			/
			(?<track>.+)
			\.
			(?<format>[^\.\n]+)
			$
		}x){
			my %h = ();
			
			$h{$_} = $+{$_} for(@$titles);
			
			push @tb, \%h;
		}
	}

	return \@tb;
}

1;
