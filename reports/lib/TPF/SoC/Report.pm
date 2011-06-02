package TPF::SoC::Report;

use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Types::URI 'Uri';
use TPF::SoC::Types 'RFC2822Date', 'Student';
use namespace::autoclean;

has student => (
    is       => 'ro',
    isa      => Student,
    required => 1,
);

has date => (
    is       => 'ro',
    isa      => RFC2822Date,
    coerce   => 1,
    required => 1,
);

has url => (
    is       => 'ro',
    isa      => Uri,
    coerce   => 1,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;
