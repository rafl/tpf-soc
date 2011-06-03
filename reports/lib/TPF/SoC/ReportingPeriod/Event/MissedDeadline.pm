package TPF::SoC::ReportingPeriod::Event::MissedDeadline;

use Moose;
use namespace::autoclean;

with qw(
    TPF::SoC::ReportingPeriod::Event
    TPF::SoC::ReportingPeriod::Event::WithExpectedNextDate
);

__PACKAGE__->meta->make_immutable;

1;
