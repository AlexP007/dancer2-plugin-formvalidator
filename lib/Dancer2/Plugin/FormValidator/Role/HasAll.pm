package Dancer2::Plugin::FormValidator::Role::HasAll;

use Moo::Role;

with 'Dancer2::Plugin::FormValidator::Role::HasProfile',
    'Dancer2::Plugin::FormValidator::Role::HasMessages';

1;
