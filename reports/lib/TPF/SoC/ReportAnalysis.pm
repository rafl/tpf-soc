package TPF::SoC::ReportAnalysis;

use Moose;
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

__PACKAGE__->meta->make_immutable;

1;
