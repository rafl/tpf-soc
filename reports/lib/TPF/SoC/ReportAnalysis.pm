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

method last_report {
    my $last_report_period = last_value {
        try { $_->last_report }
    } $self->periods;

    die 'No report available'
        unless $last_report_period;

    return $last_report_period->last_report;
}

__PACKAGE__->meta->make_immutable;

1;
