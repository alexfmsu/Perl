#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings;
use utf8;

use Local::MusicLibraryReader;
use Local::MusicLibraryFilters;
use Local::MusicLibraryPrinter;

use Local::MusicLibrary;

binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');

my @titles = ('band', 'year', 'album', 'track', 'format');
my @args = ('band', 'year', 'album', 'track', 'format', 'sort', 'columns');

MusicLibrary::print_library(\@titles, \@args);