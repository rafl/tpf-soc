package TPF::SoC::ReportAnalysis;

use Moose;
use syntax 'method';
use Try::Tiny;
use List::AllUtils 'last_value';
use MooseX::Types::Moose 'ArrayRef';
use TPF::SoC::Types 'ReportingPeriod';
use namespace::autoclean;

has periods => (
    traits   => ['Array'],
    isa      => ArrayRef[ReportingPeriod],
    required => 1,
    handles  => {
        periods     => 'elements',
        n_periods   => 'count',
        nth_period  => 'get',
    },
);

method expected_next_date {
    my $last_period_with_expectation = last_value {
        try { $_->expected_next_date }
    } $self->periods;

    die 'No expectation available'
        unless $last_period_with_expectation;

    return $last_period_with_expectation->expected_next_date;
}


__PACKAGE__->meta->make_immutable;

1;
