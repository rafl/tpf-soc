package TPF::SoC::ReportingPeriod;

use Moose;
use MooseX::Types::Moose 'ArrayRef';
use TPF::SoC::Types 'DateTimeSpan', 'ReportingEvent';
use namespace::autoclean;

has span => (
    is       => 'ro',
    isa      => DateTimeSpan,
    required => 1,
    handles  => [qw(start end)],
);

has events => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => ArrayRef[ReportingEvent],
    required => 1,
    handles  => {
        has_events => 'count',
    },
);

__PACKAGE__->meta->make_immutable;
