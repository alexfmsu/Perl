use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Reducer::Sum;

use Moose;

extends 'Local::Reducer';

has field => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

sub reduce_step{
    my($self, $next, $row_class, $initial_value) = @_;
    
    my $field = $self->field;
    
    my $res = $self->tmp_reduced_result;
    
    my $row = $row_class->new(str=>$next);

    if($row->can('get')){
        $res += $row->get($field, $initial_value);
    }else{
        die "Can't get data\n";
    }
    
    $self->tmp_reduced_result($res);
}

sub process_result{}

1;