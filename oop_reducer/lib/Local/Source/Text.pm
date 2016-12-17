use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Source::Text;

use Moose;

extends 'Local::Source';

has text => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has delimiter => (
    is => 'ro',
    isa => 'Str',
    default => '\n'
);

has '+array' => (
    lazy => 1,
    builder => 'split_text'
);

sub split_text{
    my $self = shift;
    
    my $delimiter = $self->delimiter;

    my @lines = split(/$delimiter/, $self->text);
    
    return \@lines;
};

1;



