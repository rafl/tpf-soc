package TPF::SoC::ReportingPeriod::Event::Bonus;

use Moose;
use namespace::autoclean;

with qw(
    TPF::SoC::ReportingPeriod::Event
    TPF::SoC::ReportingPeriod::Event::WithReport
    TPF::SoC::ReportingPeriod::Event::WithExpectedNextDate
);

__PACKAGE__->meta->make_immutable;

1;
