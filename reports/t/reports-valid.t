use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Path::Class;
use FindBin;

use TPF::SoC;

my $students_list = dir($FindBin::Bin)->parent->file('students');
my $reports_list = dir($FindBin::Bin)->parent->file('reports-received');

my $c = TPF::SoC->new({
    students_fh => $students_list->openr,
    reports_fh  => $reports_list->openr,
});

is exception {
    my $reports = $c->reports;
    isa_ok $_, 'TPF::SoC::Report'
        for @{ $reports };
}, undef, "$reports_list is valid";

done_testing;
