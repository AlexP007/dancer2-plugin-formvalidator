package Dancer2::Plugin::FormValidator::Role::Validator;

use Moo::Role;
use Types::Standard qw(InstanceOf);
use namespace::clean;

has plugin => (
    is       => 'ro',
    isa      => InstanceOf['Dancer2::Plugin::FormValidator'],
);

requires 'validate';
requires 'message';

sub stop_on_fail {
    return 0;
}

1;
