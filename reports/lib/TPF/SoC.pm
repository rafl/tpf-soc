package TPF::SoC;

use Moose;
use syntax 'function';
use MooseX::Types::Moose 'ArrayRef', 'HashRef';
use MooseX::Types::Path::Class 'File';
use MooseX::Types::LoadableClass 'LoadableClass';
use MooseX::Types::Common::String 'NonEmptySimpleStr';
use TPF::SoC::Types 'Student', 'Report';
use Bread::Board::Declare;
use namespace::autoclean;

has student_class => (
    is     => 'ro',
    isa    => LoadableClass,
    coerce => 1,
    value  => 'TPF::SoC::Student',
);

has student_fields => (
    is    => 'ro',
    isa   => ArrayRef[NonEmptySimpleStr],
    block => sub { [qw(nick name email project_title blog)] },
);

has student_parser => (
    is           => 'ro',
    isa          => 'TPF::SoC::RecordParser',
    dependencies => {
        fields       => 'student_fields',
        record_class => 'student_class',
    },
);

has students_fh => (
    is       => 'ro',
    required => 1,
);

has students => (
    is           => 'ro',
    isa          => HashRef[Student],
    lifecycle    => 'Singleton',
    dependencies => ['student_parser', 'students_fh'],
    block        => fun ($s) {
        return {
            map {
                ($_->nick => $_)
            } $s->param('student_parser')->parse_fh(
                $s->param('students_fh'),
            ),
        };
    },
);

has report_class => (
    is     => 'ro',
    isa    => LoadableClass,
    coerce => 1,
    value  => 'TPF::SoC::Report',
);

has report_fields => (
    is    => 'ro',
    isa   => ArrayRef[NonEmptySimpleStr],
    block => sub { [qw(student date url)] },
);

has report_args_mangler => (
    is           => 'ro',
    isa          => 'CodeRef',
    dependencies => ['students'],
    block        => fun ($s) {
        my $students = $s->param('students');
        fun ($args) {
            return {
                %{ $args },
                student => $students->{ $args->{student} },
            };
        }
    },
);

has report_parser => (
    is           => 'ro',
    isa          => 'TPF::SoC::RecordParser',
    dependencies => {
        fields       => 'report_fields',
        record_class => 'report_class',
        args_mangler => 'report_args_mangler',
    },
);

has reports_fh => (
    is       => 'ro',
    required => 1,
);

has reports => (
    is           => 'ro',
    isa          => ArrayRef[Report],
    lifecycle    => 'Singleton',
    dependencies => ['report_parser', 'reports_fh'],
    block        => fun ($s) {
        return [sort {
            $a->date <=> $b->date
        } $s->param('report_parser')->parse_fh(
            $s->param('reports_fh'),
        )];
    },
);

__PACKAGE__->meta->make_immutable;

1;
