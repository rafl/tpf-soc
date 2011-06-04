package TPF::SoC::Types;

use MooseX::Types -declare => [
    'RFC2822Date', 'ISO8601DateTime',
    'DateTimeSpan',
    'Student', 'Report', 'ReportAnalyser', 'ReportingPeriod',
    'ReportingEvent', 'ReportAnalysis',
];

use MooseX::Types::Moose 'Str';
use MooseX::Types::DateTime 'DateTime';
use DateTime::Format::Mail;
use DateTime::Format::ISO8601;

subtype RFC2822Date, as DateTime;

coerce RFC2822Date, from Str, via {
    DateTime::Format::Mail->parse_datetime($_);
};

subtype ISO8601DateTime, as DateTime;

coerce ISO8601DateTime, from Str, via {
    DateTime::Format::ISO8601->parse_datetime($_);
};

class_type DateTimeSpan, { class => 'DateTime::Span' };

class_type Student, { class => 'TPF::SoC::Student' };
class_type Report, { class => 'TPF::SoC::Report' };
class_type ReportAnalyser, { class => 'TPF::SoC::ReportAnalyser' };
class_type ReportingPeriod, { class => 'TPF::SoC::ReportingPeriod' };
class_type ReportAnalysis, { class => 'TPF::SoC::ReportAnalysis' };

role_type ReportingEvent, { role => 'TPF::SoC::ReportingPeriod::Event' };

1;
