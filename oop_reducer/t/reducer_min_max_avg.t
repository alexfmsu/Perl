use strict;
use warnings;

use Test::More tests => 12;

use FindBin; # added
use lib "$FindBin::Bin/../lib"; # added

use Local::Reducer::MinMaxAvg;
use Local::Source::Array;
use Local::Row::JSON;

my $min_max_avg_reducer = Local::Reducer::MinMaxAvg->new(
    field => 'price',
    source => Local::Source::Array->new(array => [
        '{"price": 1}',
        '{"price": 2}',
        '{"price": 3}',
    ]),
    row_class => 'Local::Row::JSON',
    initial_value => 0,
);

my $min_max_avg_result;

$min_max_avg_result = $min_max_avg_reducer->reduce_n(2);
is($min_max_avg_result->min, 1, 'min_max_avg reduced_min 1');
is($min_max_avg_result->max, 2, 'min_max_avg reduced_max 2');
is($min_max_avg_result->avg, 1.5, 'min_max_avg reduced_avg 1.5');

is($min_max_avg_reducer->reduced->min, 1, 'min_max_avg reducer_min saved');
is($min_max_avg_reducer->reduced->max, 2, 'min_max_avg reducer_max saved');
is($min_max_avg_reducer->reduced->avg, 1.5, 'min_max_avg reducer_avg saved');

$min_max_avg_result = $min_max_avg_reducer->reduce_all();
is($min_max_avg_result->min, 1, 'min_max_avg reducer_all_min');
is($min_max_avg_result->max, 3, 'min_max_avg reducer_all_max');
is($min_max_avg_result->avg, 2, 'min_max_avg reducer_all_avg');

is($min_max_avg_reducer->reduced->min, 1, 'min_max_avg reducer_all_min');
is($min_max_avg_reducer->reduced->max, 3, 'min_max_avg reducer_all_max');
is($min_max_avg_reducer->reduced->avg, 2, 'min_max_avg reducer_all_avg');
