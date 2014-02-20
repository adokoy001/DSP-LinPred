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
    # Updating Filter and Calculating Prediction Error.
    my $x = [0,0.1, ... ]; # input signal
    for( 0 .. $#{$x} ){
        my ($predicted, $error) = $lp->predict_update($x->[$_]);
    }

    # Prediction
    my $num_pred = 10;
    my $pred = $lp->predict($num_pred);
    for( 0 .. $#{$pred} ){ print $pred->[$_], "\n"; }

# DESCRIPTION

DSP::LinPred is Linear Prediction by Least Mean Squared Algorithm.

This Linear Predicting method can estimate the standard variation, direct current component, and predict future value of input.

# Methods

    $lp->set_filter();



    $lp->update_predict();

# LICENSE

Copyright (C) Toshiaki Yokoda.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Toshiaki Yokoda <>
