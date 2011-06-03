use strict;
use warnings;
use Test::More;

use FindBin;
use DateTime;
use Path::Class;
use DateTime::Event::Recurrence;

use TPF::SoC;

my $students_list = dir($FindBin::Bin)->parent->file('students');
my $reports_list = dir($FindBin::Bin)->parent->file('reports-received');

my $c = TPF::SoC->new({
    students_fh            => $students_list->openr,
    reports_fh             => $reports_list->openr,
    reporting_period_start => DateTime->new(
        year      => 2011,
        month     => 5,
        day       => 23,
        time_zone => 'UTC',
    ),
    reporting_period_end => DateTime->new(
        year      => 2011,
        month     => 8,
        day       => 22,
        time_zone => 'UTC',
    ),
    reporting_interval => DateTime::Event::Recurrence->weekly,
});

$c->report_analyser->analyse(
    @{ $c->student_reports->{$_} }
) for keys %{ $c->students };

#diag explain [map { $c->student_reports->{$_} } keys %{ $c->students }];

done_testing;
