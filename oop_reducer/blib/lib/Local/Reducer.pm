use 5.16.0;
use strict;
use warnings;
use utf8;

our $VERSION = '1.00';

package Local::Reducer;

use Moose;

has source => (
    is => 'ro',
    isa => 'Local::Source',
    required => 1
);

has row_class => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has initial_value => (
    is => 'ro',
    isa => 'Num',
    required => 1
);

has reduced_count => (
    is => 'rw',
    isa => 'Int',
    default => 0
);

has tmp_reduced_result => (
    is => 'rw',
    isa => 'Num',
    default => 0
);

has reduced_result => (
    is => 'rw',
    isa => 'Num',
    default => 0
);

our $crutch = 0;

sub reduce_n{
    my($self, $n) = @_;
    
    my $source = $self->source;
    my $row_class = $self->row_class;
    my $initial_value = $self->initial_value;
    
    my $all_mode;
    
    if(!defined($n)){
        $all_mode = 1;
        
        $n = 1;
    }elsif($n > 0){
        $all_mode = 0;
    }else{
        die "Error: Can't reduce $n values\n";
    }
    
    my $counter = 0;
    
    while($counter < $n){
        my $next = $source->next();
        
        last if(!defined($next));
        
        $self->reduce_step($next, $row_class, $initial_value);
        
        $self->reduced_count($self->reduced_count + 1);
        $counter++;
        
        $n++ if $all_mode;
    }
    
    $self->process_result();
    
    return $self->tmp_reduced_result;
}

sub reduce_all{
    my $self = shift;
    
    my $res = $self->reduce_n();
    
    $self->reduced_result($res);
    
    return $self->reduced_result;
}

sub reduced{
    my $self = shift;
    
    return $self->tmp_reduced_result;
}

1;