package TPF::SoC::ReportAnalyser;

use Moose;
use syntax 'method';
use DateTime::Duration;
use MooseX::Types::DateTime DateTime => { -as => 'DateTimeType' }, 'Duration';
use TPF::SoC::Types 'DateTimeSpan';
use namespace::autoclean;

has reporting_period => (
    is       => 'ro',
    isa      => DateTimeSpan,
    required => 1,
    handles  => {
        reporting_period_start => 'start',
    },
);

has reporting_interval => (
    is       => 'ro',
    isa      => Duration,
    required => 1,
);

method next_reporting_date ($dt) { $dt + $self->reporting_interval }

# assume reports are sorted by date
method analyse (@reports) {
    my $now = DateTime->now(time_zone => 'local');

    my $last_reporting_start = $self->reporting_period_start;
    my $last_reporting_date  = $last_reporting_start;

    my $next_reporting_deadline = $self->next_reporting_date($last_reporting_start);
    my $next_expected_reporting_date = $next_reporting_deadline;

    warn $reports[0]->student->nick;

    while ($last_reporting_start <= $now) {
        warn $next_reporting_deadline;

        if ($next_expected_reporting_date > $next_reporting_deadline) {
            die "$next_expected_reporting_date > $next_reporting_deadline";
        }

        my $reports_consumed = 0;
        while (@reports && $reports[0]->date < $next_reporting_deadline) {
            my $report = shift @reports;
            $reports_consumed++;

            $last_reporting_date = $report->date;
            $next_expected_reporting_date = $self->next_reporting_date(
                $last_reporting_date->truncate(to => 'day'),
            ) + DateTime::Duration->new(days => 1);

            warn "report before deadline (" . $report->date . ")";
            warn "(next expected at $next_expected_reporting_date)";
        }

        if ($reports_consumed > 1) {
            warn "bonus report!";
        }
        elsif (!$reports_consumed) {
            if ($next_reporting_deadline > $now) {
                if ($next_expected_reporting_date < $now) {
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

                warn "missed deadline for week until " . $next_reporting_deadline;
                warn "(next expected at $next_expected_reporting_date)";
            }
        }


        $last_reporting_start = $self->next_reporting_date($last_reporting_start);
    } continue {
        $next_reporting_deadline = $self->next_reporting_date($next_reporting_deadline);
    }

    print "\n";
}

__PACKAGE__->meta->make_immutable;

1;
