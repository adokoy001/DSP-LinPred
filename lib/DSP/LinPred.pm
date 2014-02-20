package DSP::LinPred;
use 5.008005;
use Mouse;
our $VERSION = "0.01";

has 'mu' => (
    is => 'rw',
    default => 0.001
    );
has 'h_length' => (
    is => 'rw',
    isa => 'Int',
    default => 100
    );
has 'h' => (
    is => 'rw',
    default => sub{[(0) x 100]}
    );
has 'x_stack' => (
    is => 'rw',
    default => sub{[(0) x 100]}
    );
has 'x_count' => (
    is => 'rw',
    isa => 'Int',
    default => 0
    );
has 'current_error' => (
    is => 'rw',
    default => 0
    );
has 'dc' => (
    is => 'rw',
    default => 0
    );
has 'dc_a' => (
    is => 'rw',
    default => 0.01
    );
has 'dc_mode' => (
    is => 'rw',
    isa => 'Int',
    default => 1
    );
has 'dc_init' => (
    is => 'rw',
    default => 0
    );
has 'dcd_th' => (
    is => 'rw',
    default => 1
    );

# filter specification
# mu : step size
# h_length : filter size
sub set_filter{
    my $self = shift;
    my $conf = shift;
    if(defined($conf->{mu})){
	$self->mu($conf->{mu});
    }
    if(defined($conf->{filter_length})){
	$self->h_length($conf->{filter_length});
	$self->h([(0) x $conf->{filter_length}]);
	if(defined($conf->{dc_init})){
	    $self->x_stack([($conf->{dc_init}) x $conf->{filter_length}]);
	}else{
	    $self->x_stack([(0) x $conf->{filter_length}]);
	}
    }
    if(defined($conf->{dc_mode})){
	$self->dc_mode($conf->{dc_mode});
    }
    if(defined($conf->{dc_init})){
	$self->dc($conf->{dc_init});
	$self->dc_init($conf->{dc_init});
    }
    if(defined($conf->{dcd_th})){
	$self->dcd_th($conf->{dcd_th});
    }
}

# reset filter state
sub reset_state{
    my $self = shift;
    my $h_length = $self->h_length;
    $self->h([(0) x $h_length]);
    $self->x_stack([($self->dc_init) x $h_length]);
    $self->current_error(0);
    $self->dc($self->dc_init);
    $self->x_count(0);
}

# predict and update
# this method returns estimated value and current error
sub predict_update{
    my $self = shift;
    my $x = shift;
    my $h_length = $self->h_length;
    my $h = $self->h;
    my $x_stack = $self->x_stack;
    unshift(@$x_stack,$x);
    pop(@$x_stack);
    my $dc_diff = abs($self->dc - ($x - $self->dc * $self->dc_a)/(1 - $self->dc_a));
    if(($self->dc_mode == 1) and ($dc_diff > $self->dcd_th)){
	$self->dc(($x - $self->dc * $self->dc_a)/(1 - $self->dc_a));
    }

    my $x_est = 0;
    for( my $k = 0; $k <= $#{$h} and $k <= $self->x_count;$k++){
	$x_est += $h->[$k] * ($x_stack->[$k] - $self->dc);
    }
    my $error = $x - ($x_est + $self->dc);
    $self->current_error($error);
    my $h_new = $h;
    for(my $k = 0;$k <= $#{$h} and $k <= $self->x_count; $k++){
	$h_new->[$k] = 
	    $h->[$k] 
	    + $error * $self->mu * ($x_stack->[$k] - $self->dc);
    }

    $self->h($h_new);
    $self->x_count($self->x_count + 1);

    return($x_est + $self->dc,$error);
}

# prediction only
# predict_num : number of output predicted values
# this method returns list reference of predicted values
sub predict{
    my $self = shift;
    my $predict_num = shift;
    my $h = $self->h;
    my $x_stack = $self->x_stack;
    my $estimated;
    for(1 .. $predict_num){
	my $x_est = 0;
	for( my $k = 0; $k <= $#{$h} and $k <= $self->x_count; $k++){
	    $x_est += $h->[$k] * ($x_stack->[$k] - $self->dc);
	}
	$x_est += $self->dc;
	unshift(@$x_stack,$x_est);
	push(@$estimated,$x_est);
	pop(@$x_stack);
    }
    return($estimated);
}

1;
__END__

=encoding utf-8

=head1 NAME

DSP::LinPred - Linear Prediction

=head1 SYNOPSIS

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


=head1 DESCRIPTION

DSP::LinPred is Linear Prediction by Least Mean Squared Algorithm.

This Linear Predicting method can estimate the standard variation, direct current component, and predict future value of input.

=head1 Methods

    $lp->set_filter();



    $lp->update_predict();

=head1 LICENSE

Copyright (C) Toshiaki Yokoda.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toshiaki Yokoda E<lt>E<gt>

=cut

