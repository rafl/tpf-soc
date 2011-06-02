package TPF::SoC::Student;

use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Types::URI 'Uri';
use MooseX::Types::Email 'EmailAddress';
use MooseX::Types::Common::String 'NonEmptySimpleStr';
use namespace::autoclean;

has nick => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has email => (
    is       => 'ro',
    isa      => EmailAddress,
    required => 1,
);

has project_title => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has blog => (
    is        => 'ro',
    isa       => Uri,
    coerce    => 1,
    predicate => 'has_blog',
);

__PACKAGE__->meta->make_immutable;

1;
