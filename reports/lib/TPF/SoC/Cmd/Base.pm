package TPF::SoC::Cmd::Base;

use Moose;
use syntax 'method';
use TPF::SoC;
use FindBin '$Bin';
use Path::Class;
use MooseX::Types::Path::Class 'File';
use namespace::autoclean;

extends 'MooseX::App::Cmd::Command';

my $base_dir = dir($Bin)->parent;

has config_file => (
    is      => 'ro',
    isa     => File,
    coerce  => 1,
    default => sub { $base_dir->file('tpf-soc.json') },
);

has students_list => (
    is      => 'ro',
    isa     => File,
    coerce  => 1,
    default => sub { $base_dir->file('students') },
);

has reports_list => (
    is      => 'ro',
    isa     => File,
    coerce  => 1,
    default => sub { $base_dir->file('reports-received') },
);

has container => (
    is      => 'ro',
    isa     => 'TPF::SoC',
    lazy    => 1,
    builder => '_build_container',
);

method _build_container {
    TPF::SoC->new({
        students_fh => $self->students_list->openr,
        reports_fh  => $self->reports_list->openr,
        config_file => $self->config_file,
    });
}

method BUILD {
    $self->container;
}

__PACKAGE__->meta->make_immutable;

1;
