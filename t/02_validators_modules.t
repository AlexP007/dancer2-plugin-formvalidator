use strict;
use warnings;
use Test::More tests => 3;

# TEST 1.
use_ok('Dancer2::Plugin::FormValidator::Validators::Required');

# TEST 2.
use_ok('Dancer2::Plugin::FormValidator::Validators::Email');

# TEST 3.
use_ok('Dancer2::Plugin::FormValidator::Validators::EmailDns');
