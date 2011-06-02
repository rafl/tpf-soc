package TPF::SoC::RecordParser;

use Moose;
use syntax 'method';
use Path::Class;
use List::AllUtils 'zip';
use MooseX::Types::Moose 'ArrayRef', 'Str';
use MooseX::Types::LoadableClass 'LoadableClass';
use namespace::autoclean;

has record_class => (
    is       => 'ro',
    isa      => LoadableClass,
    required => 1,
    coerce   => 1,
    handles  => {
        new_record => 'new',
    },
);

has args_mangler => (
    traits  => ['Code'],
    default => sub { sub { @_ } },
    handles => {
        mangle_args => 'execute',
    },
);

has fields => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => ArrayRef[Str],
    required => 1,
    handles  => {
        n_fields => 'count',
    },
);

method parse_file ($file) {
    $self->parse_fh( file($file)->openr );
}

method parse_fh ($fh) {
    my @records;

    while (my $line = <$fh>) {
        next if $self->_is_comment($line);

        my @values = $self->_parse_line($fh->input_line_number => $line);
        push @records, $self->_construct_record(@values);
    }

    return @records;
}

# | ... | ... | ... |
method _parse_line ($n, $line) {
    chomp $line;
    my @v = map {
        s/^\s*//;
        s/\s*$//;
        $_;
    } split /\|/, $line;
    shift @v;

    confess sprintf('Unexpected number of values on line %d (expected %d, got %d)',
                    $n, $self->n_fields, scalar @v)
        unless @v == $self->n_fields;

    return map {
        length $_ ? $_ : undef;
    } @v;
}

method _construct_record (@values) {
    my %init_args = zip @{ $self->fields }, @values;
    !defined $init_args{$_} && delete $init_args{$_}
        for keys %init_args;

    return $self->new_record(
        $self->mangle_args(\%init_args),
    );
}

method _is_comment ($line) {
    $line =~ /(?:^#)|(?:^\s*$)/
}

__PACKAGE__->meta->make_immutable;

1;
