use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Source;

use Moose;

use Local::Row;

has array => (
    is => 'rw',
    isa => 'ArrayRef'
);

has ind => (
    is => 'rw',
    default => 0
);

has row_class => (
    is => 'ro',
    isa => 'Str'
);

sub next{
    my $self = shift;
    
    my $arr = $self->array;
    
    my $ind = \($self->{ind});
    
    if(@$arr && $$ind < scalar @$arr){
        return @$arr[$$ind++];
    }else{
        return undef;
    }
}

1;