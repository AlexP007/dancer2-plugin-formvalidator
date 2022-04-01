use strict;
use warnings;
use utf8::all;
use Test::More tests => 9;

use Dancer2::Plugin::FormValidator::Validators::Required;
use Dancer2::Plugin::FormValidator::Validators::Email;
use Dancer2::Plugin::FormValidator::Validators::EmailDns;

my $validator;

# TEST 1.
## Check Dancer2::Plugin::FormValidator::Validators::Required.

$validator = Dancer2::Plugin::FormValidator::Validators::Required->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 1: Dancer2::Plugin::FormValidator::Validators::Required messages hash'
);

is(
    $validator->stop_on_fail,
    1,
    'TEST 1: Dancer2::Plugin::FormValidator::Validators::Required stop_on_fail',
);

is(
    $validator->validate('email', {}),
    '',
    'TEST 1: Dancer2::Plugin::FormValidator::Validators::Required validate',
);

# TEST 2.
## Check Dancer2::Plugin::FormValidator::Validators::Email.

$validator = Dancer2::Plugin::FormValidator::Validators::Email->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 2: Dancer2::Plugin::FormValidator::Validators::Email messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 2: Dancer2::Plugin::FormValidator::Validators::Email stop_on_fail',
);

is(
    $validator->validate('email', {email => 'alexpan.org'}),
    0,
    'TEST 2: Dancer2::Plugin::FormValidator::Validators::Email validate',
);

# TEST 3.
## Check Dancer2::Plugin::FormValidator::Validators::EmailDns.

$validator = Dancer2::Plugin::FormValidator::Validators::EmailDns->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 3: Dancer2::Plugin::FormValidator::Validators::EmailDns messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 3: Dancer2::Plugin::FormValidator::Validators::EmailDns stop_on_fail',
);

is(
    $validator->validate('email', {email => 'alexpan@crfssfd.com'}),
    0,
    'TEST 3:Dancer2::Plugin::FormValidator::Validators::EmailDns validate',
);
