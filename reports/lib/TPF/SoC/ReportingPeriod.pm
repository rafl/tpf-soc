package TPF::SoC::ReportingPeriod;

use 5.010;
use Moose;
use syntax 'method';
use DateTime;
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
    isa      => ArrayRef[ReportingEvent],
    required => 1,
    handles  => {
        events     => 'elements',
        has_events => 'count',
    },
);

method finished ($dt) {
    $dt //= DateTime->now(time_zone => 'local');
    return $self->end < $dt;
}

__PACKAGE__->meta->make_immutable;
