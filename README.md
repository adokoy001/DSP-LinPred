# NAME

DSP::LinPred - Linear Prediction

# SYNOPSIS

    use LinPred;

    # Creating Object.
    # mu       : Step size of filter. (default = 0.001)
    # h_length : Filter size. (default = 100)
    # dc_mode  : Direct Current Component estimation.
    #            it challenges to estimating DC component if set 1.
    #            automatically by IIR filter in updating phase.
    #            (default = 1 enable)
    # dc_init  : Initial DC bias.
    #            It *SHOULD* be set value *ACCURATELY* if dc_mode => 0.
    #            (default = 0)
    # dc_a     : Coefficient of IIR filter.
    #            Untouching is better. (default = 0.01)
    # dcd_th   : Convergence threshold value for DC component estimation.
    #            (default = 1)
    my $lp = DSP::LinPred->new;
    $lp->set_filter({
                     mu => 0.001,
                     h_length => 100,
                     dc_mode => 0,
                     dc_init => 1
                    });

    # defining signal x
    my $x = [0,0.1,0.5, ... ]; # input signal

    # Updating Filter
    $lp->update($x);
    my $current_error = $lp->current_error; # get error

    # Prediction
    my $num_pred = 10;
    my $pred = $lp->predict($num_pred);
    for( 0 .. $#{$pred} ){ print $pred->[$_], "\n"; }

# DESCRIPTION

DSP::LinPred is Linear Prediction by Least Mean Squared Algorithm.

This Linear Predicting method can estimate the standard variation, direct current component, and predict future value of input.

# Methods
=head2 _set\_filter_
_set\_filter_ method sets filter specifications to DSP::LinPred object.

    $lp->set_filter(
        {
            mu => $step_size, # <Num>
            h_length => $filter_length, # <Int>
            h => $initial_filter_state, # <ArrayRef[Num]>
            dc_init => $initial_dc_bias, # <Num>
            dc_mode => $dc_estimation, # <Int>, enable when 1
            dcd_th => $dc_est_threshold # <Num>
        });

## _update_
_update_ method updates filter state by source inputs are typed ArrayRef\[Num\].
    my $x = \[0.13,0.3,-0.2,0.5,-0.07\];
    $lp->update($x);

If you would like to extract the filter state, you can access member variable directly like below.

    my $filter = $lp->h;
    for( 0 .. $#$filter ){ print $filter->[$_], "\n"; }

## _predict_
_predict_ method generates predicted future values of inputs by filter.

    my $predicted = $lp->predict(7);
    for( 0 .. $#$predicted){ print $predicted->[$_], "\n";}

# LICENSE

Copyright (C) Toshiaki Yokoda.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Toshiaki Yokoda <>
