package TPF::SoC::ReportingPeriod::Event::MissedExpectedDeadline;

use Moose;
use MooseX::Types::DateTime 'DateTime';
use namespace::autoclean;

with 'TPF::SoC::ReportingPeriod::Event';

__PACKAGE__->meta->make_immutable;

1;
