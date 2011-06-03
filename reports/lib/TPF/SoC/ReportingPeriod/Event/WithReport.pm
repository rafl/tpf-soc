package TPF::SoC::ReportingPeriod::Event::WithReport;

use Moose::Role;
use TPF::SoC::Types 'Report';
use namespace::autoclean;

has report => (
    is       => 'ro',
    isa      => Report,
    required => 1,
);

1;
