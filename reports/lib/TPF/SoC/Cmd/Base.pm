package TPF::SoC::Cmd::Base;

use Moose;
use syntax 'method';
use TPF::SoC;
use Try::Tiny;
use FindBin '$Bin';
use Path::Class;
use Log::Dispatchouli;
use MooseX::Types::Moose 'Bool';
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

has debug => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has logger => (
    is      => 'ro',
    isa     => 'Log::Dispatchouli',
    handles => qr/^log_/,
    builder => '_build_logger',
);

method _build_logger {
    Log::Dispatchouli->new({
        to_stderr => 1,
        debug     => $self->debug,
        ident     => sprintf('%s/%s', $self->app->arg0, blessed $self),
    });
}

method BUILD {
    $self->container;
    $self->logger;
}

__PACKAGE__->meta->make_immutable;

1;
