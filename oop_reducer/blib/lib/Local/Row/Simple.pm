use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Row::Simple;

use Moose;

extends 'Local::Row';

has '+data' => (
    lazy_build => 1,
    builder => 'data_builder'
);

sub data_builder{
    my $self = shift;

    my $str = $self->str;

    my %h = ();
    
    $str =~ m{
        ^
        (?:
            (?>
                (?<key> [^\:\,]+) \: (?<value> [^\:\,]+) \,?
            )
            
            (?{
                $h{$+{key}} = 0+$+{value};
            })      
        )*
        $
    }x;
    
    $h{$+{key}} = $+{value};
    
    return \%h;
}

1;