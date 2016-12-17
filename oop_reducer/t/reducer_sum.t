use strict;
use warnings;

use FindBin; # added
use lib "$FindBin::Bin/../lib"; # added

use Test::More tests => 8;

use Local::Reducer::Sum;
use Local::Source::Array;
use Local::Row::JSON;

my $sum_reducer = Local::Reducer::Sum->new(
    field => 'price',
    source => Local::Source::Array->new(array => [
        '{"price": 1}',
        '{"price": 2}',
        '{"price": 3}',
    ]),
    row_class => 'Local::Row::JSON',
    initial_value => 0,
);

my $sum_result;

$sum_result = $sum_reducer->reduce_n(1);
is($sum_result, 1, 'sum reduced 1');
is($sum_reducer->reduced, 1, 'sum reducer saved');

$sum_result = $sum_reducer->reduce_all();
is($sum_result, 6, 'sum reduced all');
is($sum_reducer->reduced, 6, 'sum reducer saved at the end');

# -------------------------------------------------------------------------------------------------
use Local::Source::FileHandler;

use FileHandle;

my $fh = FileHandle->new("t/file", "r");
$sum_reducer = $sum_reducer = Local::Reducer::Sum->new(
    field => 'price',
    source => Local::Source::FileHandler->new(fh => $fh),
    row_class => 'Local::Row::JSON',
    initial_value => 0,
);

$sum_result = $sum_reducer->reduce_n(2);
is($sum_result, 16, 'sum reduced 1');

$sum_result = $sum_reducer->reduce_n(1);
is($sum_result, 30, 'sum reduced 1');

$sum_result = $sum_reducer->reduce_all();
is($sum_result, 30, 'sum reduced all');

is($sum_reducer->reduced, 30, 'sum reducer saved at the end');
