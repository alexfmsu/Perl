use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Row;

use Moose;

has str => (
    is => 'ro',
    isa => 'Str',
);

has data => (
    is => 'rw',
    isa => 'HashRef'
);

sub get{
    my($self, $name, $default) = @_;

    my $h = $self->data;

    my $val = $h->{$name};

    return defined($val) ? $val : $default;
}


1;