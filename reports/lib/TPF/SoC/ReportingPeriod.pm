package TPF::SoC::ReportingPeriod;

use Moose;
use TPF::SoC::Types 'DateTimeSpan';
use namespace::autoclean;

has span => (
    is       => 'ro',
    isa      => DateTimeSpan,
    required => 1,
    handles  => [qw(start end)],
);

has events => (
    is => 'ro',
);

__PACKAGE__->meta->make_immutable;
