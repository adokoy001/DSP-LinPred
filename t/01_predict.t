use strict;
use Test::More;
use LinPred;

my $dc_mode = 1;
my $dc = 10;
my $power = 1;

my $hosei = $dc_mode * $dc;

my $pi = 4 * atan2(1,1);
my $max_iter = 1000;
my $pred_length = 500;
my $filter_length = 200;
my $term = 50;
my $freq = 1 / $term;
my $orig;
my $final_error;
my $lms = LinPred->new();
$lms->set_filter(
    {
        mu => 0.0001,
        filter_length => $filter_length,
        dc_mode => $dc_mode,
        dc_init => $dc - $hosei,
        dcd_th => 2
    }
    );

for(my $k=0;$k<$max_iter;$k++){
    my $x =
        $power*(sin(2*$pi*$freq*$k)
                + 0.5*cos(0.5*2*$pi*$freq*$k)
                - 0.5*cos(0.1*2*$pi*$freq*($k+10))
        ) + $dc;
    push(@$orig,$x);
    my ($estimate,$error) = $lms->predict_update($x);
    $final_error = $error;
}

ok($final_error == -0.10047807219178);

done_testing;

