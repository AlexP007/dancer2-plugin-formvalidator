use strict;
use warnings;
use Test::More tests => 9;

# TEST 1.
use_ok('Dancer2::Plugin::FormValidator');

# TEST 2.
use_ok('Dancer2::Plugin::FormValidator::Config');

# TEST 3.
use_ok('Dancer2::Plugin::FormValidator::Processor');

# TEST 4.
use_ok('Dancer2::Plugin::FormValidator::Registry');

# TEST 5.
use_ok('Dancer2::Plugin::FormValidator::Result');

# TEST 6.
use_ok('Dancer2::Plugin::FormValidator::Role::HasProfile');

# TEST 7.
use_ok('Dancer2::Plugin::FormValidator::Role::HasMessages');

# TEST 8.
use_ok('Dancer2::Plugin::FormValidator::Role::HasProfileMessages');

# TEST 9.
use_ok('Dancer2::Plugin::FormValidator::Role::Validator');
