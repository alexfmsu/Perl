use 5.16.0;
use strict;
use warnings;
use utf8;

package MinMaxAvgObj;

use Moose;

has min => (
    is => 'rw',
    isa => 'Num',
);

has max => (
    is => 'rw',
    isa => 'Num',
);

has avg => (
    is => 'rw',
    isa => 'Num'
);

sub get_min{
    my $self = shift;
    
    return $self->min;
}

sub get_max{
    my $self = shift;
    
    return $self->max;
}

sub get_avg{
    my $self = shift;
    
    return $self->avg;
}

# -------------------------------------------------------------------------------------------------

package Local::Reducer::MinMaxAvg;

use Moose;

extends 'Local::Reducer';

has field => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has sum => (
    is => 'rw',
    isa => 'Num',
    default => 0
);

has reduced_result => (
    is => 'rw',
    isa => 'MinMaxAvgObj'
);

has tmp_reduced_result => (
    is => 'rw',
    isa => 'MinMaxAvgObj',
    default => sub{ return MinMaxAvgObj->new(); }
);

sub reduce_step{
    my($self, $next, $row_class, $initial_value) = @_;
    
    my $field = $self->field;
     
    my $res = $self->tmp_reduced_result;
    
    my $sum = $self->sum;
    
    my $reduced_count = $self->reduced_count;
    
    my $row = $row_class->new(str=>$next);

    if($row->can('get')){
        my $val = $row->get($field, $initial_value);
        
        if($reduced_count == 0 || $val < $res->min){
            $res->min($val);            
        }
        
        if($reduced_count == 0 || $val > $res->max){
            $res->max($val);            
        }
        
        $sum += $val; 
        
        $self->sum($sum);       
    }else{
        die "Can't get data";
    }
    
    $self->tmp_reduced_result($res);
}

sub process_result{
    my $self = shift;
    
    my $res = $self->tmp_reduced_result;
    
    my $sum = $self->sum;
    
    my $reduced_count = $self->reduced_count;
    
    if($reduced_count != 0){
        $res->avg($sum/$reduced_count);
    }else{
        $res = undef;
    }
    
    $self->tmp_reduced_result($res);
}

1;