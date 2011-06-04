package TPF::SoC::ReportingPeriod;

use 5.010;
use Moose;
use syntax 'method';
use DateTime;
use Moose::Util 'does_role';
use List::AllUtils 'last_value', 'any';
use MooseX::Types::Moose 'ArrayRef';
use TPF::SoC::Types 'DateTimeSpan', 'ReportingEvent';
use aliased 'TPF::SoC::ReportingPeriod::Event::MissedDeadline', 'MissedDeadlineEvent';
use aliased 'TPF::SoC::ReportingPeriod::Event::MissedExpectedDeadline', 'MissedExpectedDeadlineEvent';
use aliased 'TPF::SoC::ReportingPeriod::Event::WithExpectedNextDate', 'EventWithExpectedNextDate';
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

method expected_next_date {
    my $last_with_expected_date = last_value {
        does_role $_, EventWithExpectedNextDate
    } $self->events;

    die 'No expectation available'
        unless $last_with_expected_date;

    return $last_with_expected_date->expected_next_date;
}

method was_naughty {
    any { $_->isa(MissedDeadlineEvent) } $self->events;
}

method was_impolite {
    $self->was_naughty || any {
        $_->isa(MissedExpectedDeadlineEvent)
    } $self->events;
}

__PACKAGE__->meta->make_immutable;
