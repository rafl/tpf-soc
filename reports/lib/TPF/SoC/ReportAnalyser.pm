package TPF::SoC::ReportAnalyser;

use Moose;
use syntax 'method';
use DateTime::Span;
use DateTime::Duration;
use MooseX::Types::DateTime DateTime => { -as => 'DateTimeType' }, 'Duration';
use TPF::SoC::Types 'DateTimeSpan';
use aliased 'TPF::SoC::ReportAnalysis', 'Analysis';
use aliased 'TPF::SoC::ReportingPeriod';
use aliased 'TPF::SoC::ReportingPeriod::Event::Timely', 'TimelyReportEvent';
use aliased 'TPF::SoC::ReportingPeriod::Event::Bonus', 'BonusReportEvent';
use aliased 'TPF::SoC::ReportingPeriod::Event::MissedDeadline', 'MissedDeadlineEvent';
use aliased 'TPF::SoC::ReportingPeriod::Event::MissedExpectedDeadline', 'MissedExpectedDeadlineEvent';
use namespace::autoclean;

has reporting_period => (
    is       => 'ro',
    isa      => DateTimeSpan,
    required => 1,
    handles  => {
        map { ("reporting_period_${_}" => $_) } qw(start end),
    },
);

has reporting_interval => (
    is       => 'ro',
    isa      => Duration,
    required => 1,
);

has analysis_time => (
    is       => 'ro',
    isa      => DateTimeType,
    required => 1,
);

method next_reporting_date ($dt) { $dt + $self->reporting_interval }

{
    my $one_day = DateTime::Duration->new(days => 1);
    method _round_up_one_day ($dt) { $dt + $one_day }
}

# assume reports are sorted by date
method analyse (@reports) {
    my $now = $self->analysis_time;

    my $last_reporting_start = $self->reporting_period_start;
    my $next_reporting_start = $self->next_reporting_date($last_reporting_start);

    my $next_reporting_deadline = $self->next_reporting_date($last_reporting_start);
    my $next_expected_reporting_date = $next_reporting_deadline;

    my @reporting_periods;
    while ($last_reporting_start <= $now && $next_reporting_start < $self->reporting_period_end) {
        my @reports_before_deadline;
        while (@reports && $reports[0]->date < $next_reporting_deadline) {
            push @reports_before_deadline, shift @reports;
        }

        my @reports_in_period = grep {
            $_->date > $last_reporting_start
        } @reports_before_deadline;

        my @events;
        my $seen_timely_report = 0;
        for my $report (@reports_before_deadline) {
            $next_expected_reporting_date = $self->_round_up_one_day(
                $self->next_reporting_date(
                    $report->date->clone->truncate(to => 'day'),
                ),
            );

            my $event_class =
                  $report->date < $last_reporting_start ? BonusReportEvent
                : $seen_timely_report++                 ? BonusReportEvent
                :                                         TimelyReportEvent;

            push @events, $event_class->new({
                date               => $report->date,
                report             => $report,
                expected_next_date => $next_expected_reporting_date,
            });
        }

        unless (@reports_in_period) {
            if ($next_reporting_deadline > $now) {
                if ($next_expected_reporting_date < $now) {
                    push @events, MissedExpectedDeadlineEvent->new({
                        date          => $now,
                        expected_date => $next_expected_reporting_date,
                    });
                }
                # else { no report yet, but we didn't expect it yet anyway }
            }
            else {
                $next_expected_reporting_date = $self->next_reporting_date(
                    $next_expected_reporting_date,
                );

                push @events, MissedDeadlineEvent->new({
                    date               => $next_reporting_deadline,
                    expected_next_date => $next_expected_reporting_date,
                });
            }
        }

        push @reporting_periods, ReportingPeriod->new({
            events => \@events,
            span   => DateTime::Span->new(
                start => $last_reporting_start,
                end   => $next_reporting_deadline,
            ),
        });

        $last_reporting_start = $next_reporting_start;
        $next_reporting_start = $self->next_reporting_date($last_reporting_start);
        $next_reporting_deadline = $self->next_reporting_date($next_reporting_deadline);
    }

    return Analysis->new({
        periods => \@reporting_periods,
    });
}

__PACKAGE__->meta->make_immutable;

1;
