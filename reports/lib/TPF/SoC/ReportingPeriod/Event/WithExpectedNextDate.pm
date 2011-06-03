package TPF::SoC::ReportingPeriod::Event::WithExpectedNextDate;

use Moose::Role;
use MooseX::Types::DateTime 'DateTime';
use namespace::autoclean;

has expected_next_date => (
    is       => 'ro',
    isa      => DateTime,
    required => 1,
);

1;
