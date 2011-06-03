package TPF::SoC::ReportingPeriod::Event;

use Moose::Role;
use MooseX::Types::DateTime 'DateTime';
use namespace::autoclean;

has date => (
    is       => 'ro',
    isa      => DateTime,
    required => 1,
);

1;
