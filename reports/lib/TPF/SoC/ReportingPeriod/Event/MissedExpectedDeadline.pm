package TPF::SoC::ReportingPeriod::Event::MissedExpectedDeadline;

use Moose;
use MooseX::Types::DateTime 'DateTime';
use namespace::autoclean;

with 'TPF::SoC::ReportingPeriod::Event';

has expected_date => (
    is       => 'ro',
    isa      => DateTime,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;
