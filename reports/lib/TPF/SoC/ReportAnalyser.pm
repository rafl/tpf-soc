package TPF::SoC::ReportAnalyser;

use Moose;
use syntax 'method';
use DateTime::Span;
use DateTime::Duration;
use MooseX::Types::DateTime DateTime => { -as => 'DateTimeType' }, 'Duration';
use TPF::SoC::Types 'DateTimeSpan';
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
        map { ("reporting_period_${_}" => $_) }qw(start end),
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

# assume reports are sorted by date
method analyse (@reports) {
    my $now = $self->analysis_time;

    my $last_reporting_start = $self->reporting_period_start;
    my $next_reporting_start = $self->next_reporting_date($last_reporting_start);

    my $next_reporting_deadline = $self->next_reporting_date($last_reporting_start);
    my $next_expected_reporting_date = $next_reporting_deadline;

    warn $reports[0]->student->nick;

    my @reporting_periods;

    while ($last_reporting_start <= $now && $next_reporting_start < $self->reporting_period_end) {
        warn $next_reporting_deadline;

        my @events;

        if ($next_expected_reporting_date > $next_reporting_deadline) {
            die "$next_expected_reporting_date > $next_reporting_deadline";
        }

        my @reports_in_period;
        while (@reports && $reports[0]->date < $next_reporting_deadline) {
            push @reports_in_period, shift @reports;
        }

        for my $report (@reports_in_period) {
            $next_expected_reporting_date = $self->next_reporting_date(
                $report->date->clone->truncate(to => 'day'),
            ) + DateTime::Duration->new(days => 1);

            my $event_class = @reports_in_period > 1
                ? BonusReportEvent : TimelyReportEvent;

            push @events, $event_class->new({
                date               => $report->date,
                report             => $report,
                expected_next_date => $next_expected_reporting_date,
            });

            warn "report before deadline (" . $report->date . ")";
            warn "(next expected at $next_expected_reporting_date)";
        }

        unless (@reports_in_period) {
            if ($next_reporting_deadline > $now) {
                if ($next_expected_reporting_date > $now) {
                    push @events, MissedExpectedDeadlineEvent->new({
                        date          => $now,
                        expected_date => $next_expected_reporting_date,
                    });

                    warn "no report yet for week until " . $next_reporting_deadline
                        . " even though it was expected to arrive before " . $next_expected_reporting_date;
                }
                else {
                    warn "no report yet for week until " . $next_reporting_deadline;
                }
            }
            else {
                $next_expected_reporting_date = $self->next_reporting_date(
                    $next_expected_reporting_date,
                );

                push @events, MissedDeadlineEvent->new({
                    date               => $next_reporting_deadline,
                    expected_next_date => $next_expected_reporting_date,
                });

                warn "missed deadline for week until " . $next_reporting_deadline;
                warn "(next expected at $next_expected_reporting_date)";
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

    print "\n";

    return \@reporting_periods;
}

__PACKAGE__->meta->make_immutable;

1;
