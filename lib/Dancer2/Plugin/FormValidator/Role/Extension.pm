package Dancer2::Plugin::FormValidator::Role::Extension;

use Moo::Role;
use Types::Standard qw(InstanceOf HashRef);
use namespace::clean;

has plugin => (
    is  => 'ro',
    isa => InstanceOf ['Dancer2::Plugin::FormValidator'],
);

has config => (
    is  => 'ro',
    isa => HashRef,
);

requires 'validators';

1;
