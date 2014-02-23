use strict;
use Test::More;
use DSP::LinPred;

my $dc_mode = 1;
my $stddev_mode = 1;
my $dc = 1;
my $power = 1;

my $hosei = $dc_mode * $dc;

my $pi = 4 * atan2(1,1);
my $max_iter = 1000;
my $pred_length = 300;
my $filter_length = 300;
my $term = 50;
my $freq = 1 / $term;
my $orig;
my $lp = DSP::LinPred->new();
$lp->set_filter(
    {
        mu => 0.0001,
        filter_length => $filter_length,
        dc_mode => $dc_mode,
        dc_init => $dc - $hosei,
	stddev_mode => $stddev_mode
    }
    );

for(my $k=0;$k<$max_iter;$k++){
    my $x =
        $power*(sin(2*$pi*$freq*$k)
                + 0.5*cos(0.5*2*$pi*$freq*$k)
                - 0.5*cos(0.1*2*$pi*$freq*($k+10))
        ) + $dc;
    push(@$orig,$x);
}
$lp->update($orig);
cmp_ok($lp->current_error ,'eq', -0.000143290744717639, 'METHOD update 1');
my $predicted = $lp->predict(1);
cmp_ok($predicted->[0], 'eq', 0.876972947222487, 'METHOD predict 2');
$lp->reset_state;
$dc_mode = 0;
$hosei = $dc_mode * $dc;
$lp->set_filter(
    {
        mu => 0.0001,
        filter_length => $filter_length,
        dc_mode => $dc_mode,
        dc_init => $dc - $hosei,
	stddev_mode => $stddev_mode
    }
    );
$lp->update($orig);
$predicted = $lp->predict(1);
cmp_ok($lp->current_error ,'eq', 0.00141660731807947, 'METHOD update 2');
cmp_ok($predicted->[0], 'eq', 0.875901606238308, 'METHOD predict 2');


done_testing;

