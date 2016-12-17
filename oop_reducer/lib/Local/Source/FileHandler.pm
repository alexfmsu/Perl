use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Source::FileHandler;

use Moose;

extends 'Local::Source';

has fh => (
    is => 'ro',
    isa => 'FileHandle',
    required => 1
);

has '+array' => (
    lazy_build => 1,
    builder => 'split_file'
);

sub split_file{
    my $self = shift;
    
    my $fh = $self->fh;
    
    my @lines = <$fh>;
    
    close($fh);

    return \@lines;
}

1;
