package Dancer2::Plugin::FormValidator::Result;

use Moo;
use Types::Standard qw(InstanceOf ArrayRef Bool);
use namespace::clean;

has success => (
    is       => 'ro',
    isa      => Bool,
    required => 1,
);

has invalid => (
    is       => 'ro',
    isa      => ArrayRef,
    required => 1,
);

has valid => (
    is       => 'ro',
    isa      => ArrayRef,
    required => 1,
);

has messages => (
    is       => 'ro',
    isa      => InstanceOf['Hash::MultiValue'],
    required => 1,
);

1;
