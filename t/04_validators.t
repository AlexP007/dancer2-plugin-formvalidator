use strict;
use warnings;
use utf8::all;
use Test::More tests => 40;

use Dancer2::Plugin::FormValidator::Validator::Alpha;
use Dancer2::Plugin::FormValidator::Validator::AlphaNum;
use Dancer2::Plugin::FormValidator::Validator::Enum;
use Dancer2::Plugin::FormValidator::Validator::Email;
use Dancer2::Plugin::FormValidator::Validator::EmailDns;
use Dancer2::Plugin::FormValidator::Validator::Numeric;
use Dancer2::Plugin::FormValidator::Validator::Integer;
use Dancer2::Plugin::FormValidator::Validator::Required;
use Dancer2::Plugin::FormValidator::Validator::Same;

my $validator;

# TEST 1.
## Check Dancer2::Plugin::FormValidator::Validators::Required.

$validator = Dancer2::Plugin::FormValidator::Validator::Required->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 1: Dancer2::Plugin::FormValidator::Validator::Required messages hash'
);

is(
    $validator->stop_on_fail,
    1,
    'TEST 1: Dancer2::Plugin::FormValidator::Validator::Required stop_on_fail',
);

isnt(
    $validator->validate('email', {}),
    1,
    'TEST 1: Dancer2::Plugin::FormValidator::Validator::Required: not valid',
);


is(
    $validator->validate('email', {email => ''}),
    1,
    'TEST 1: Dancer2::Plugin::FormValidator::Validator::Required: valid',
);

# TEST 2.
## Check Dancer2::Plugin::FormValidator::Validators::Email.

$validator = Dancer2::Plugin::FormValidator::Validator::Email->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 2: Dancer2::Plugin::FormValidator::Validator::Email messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 2: Dancer2::Plugin::FormValidator::Validator::Email stop_on_fail',
);

isnt(
    $validator->validate('email', {email => 'alexpan.org'}),
    1,
    'TEST 2: Dancer2::Plugin::FormValidator::Validator::Email: not valid',
);

is(
    $validator->validate('email', {email => 'alex@cpan.org'}),
    1,
    'TEST 2: Dancer2::Plugin::FormValidator::Validator::Email: valid',
);

# TEST 3.
## Check Dancer2::Plugin::FormValidator::Validators::EmailDns.

$validator = Dancer2::Plugin::FormValidator::Validator::EmailDns->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 3: Dancer2::Plugin::FormValidator::Validator::EmailDns messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 3: Dancer2::Plugin::FormValidator::Validator::EmailDns stop_on_fail',
);

isnt(
    $validator->validate('email', {email => 'alexpan@crfssfd.com'}),
    1,
    'TEST 3: Dancer2::Plugin::FormValidator::Validator::EmailDns: not valid',
);

is(
    $validator->validate('email', {email => 'alex@cpan.org'}),
    1,
    'TEST 3: Dancer2::Plugin::FormValidator::Validator::EmailDns: valid',
);

# TEST 4.
## Check Dancer2::Plugin::FormValidator::Validators::Same.

$validator = Dancer2::Plugin::FormValidator::Validator::Same->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 4: Dancer2::Plugin::FormValidator::Validators::Same messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 4: Dancer2::Plugin::FormValidator::Validators::Same stop_on_fail',
);

isnt(
    $validator->validate(
        'password',
        {password => 'pass', password_cnf => ''},
        'password_cnf'
    ),
    1,
    'TEST 4: Dancer2::Plugin::FormValidator::Validators::Same: not valid',
);

isnt(
    $validator->validate(
        'password',
        {password => [], password_cnf => ''},
        'password_cnf'
    ),
    1,
    'TEST 4: Dancer2::Plugin::FormValidator::Validators::Same: not valid',
);

isnt(
    $validator->validate(
        'password',
        {password => undef},
        'password_cnf'
    ),
    1,
    'TEST 4: Dancer2::Plugin::FormValidator::Validators::Same: not valid',
);

is(
    $validator->validate(
        'password',
        {password => 12345, password_cnf => 12345},
        'password_cnf'),
    1,
    'TEST 4: Dancer2::Plugin::FormValidator::Validators::Same: valid',
);

is(
    $validator->validate(
        'password',
        {password => 'pass', password_cnf => 'pass'},
        'password_cnf'),
    1,
    'TEST 4: Dancer2::Plugin::FormValidator::Validators::Same: valid',
);

# TEST 5.
## Check Dancer2::Plugin::FormValidator::Validators::Enum.

$validator = Dancer2::Plugin::FormValidator::Validator::Enum->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 5: Dancer2::Plugin::FormValidator::Validator::Enum messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 5: Dancer2::Plugin::FormValidator::Validator::Enum stop_on_fail',
);

isnt(
    $validator->validate('type', {type => 'child'}, 'credit', 'debit'),
    1,
    'TEST 5: Dancer2::Plugin::FormValidator::Validator::Enum: not valid',
);

is(
    $validator->validate('type', {type => 'credit'}, 'credit', 'debit'),
    1,
    'TEST 5: Dancer2::Plugin::FormValidator::Validator::Enum: valid',
);

# TEST 6.
## Check Dancer2::Plugin::FormValidator::Validators::Numeric.

$validator = Dancer2::Plugin::FormValidator::Validator::Numeric->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 6: Dancer2::Plugin::FormValidator::Validator::Numeric messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 6: Dancer2::Plugin::FormValidator::Validator::Numeric stop_on_fail',
);

isnt(
    $validator->validate('price', {price => '0.13d'}),
    1,
    'TEST 6: Dancer2::Plugin::FormValidator::Validator::Numeric: not valid',
);

is(
    $validator->validate('price', {price => '0.13'}),
    1,
    'TEST 6: Dancer2::Plugin::FormValidator::Validator::Numeric: valid',
);

# TEST 7.
## Check Dancer2::Plugin::FormValidator::Validators::Alpha.

$validator = Dancer2::Plugin::FormValidator::Validator::Alpha->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 7: Dancer2::Plugin::FormValidator::Validator::Alpha messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 7: Dancer2::Plugin::FormValidator::Validator::Alpha stop_on_fail',
);

isnt(
    $validator->validate('username', {username => 'Ahмед23'}),
    1,
    'TEST 7: Dancer2::Plugin::FormValidator::Validator::Alpha: not valid',
);

is(
    $validator->validate('username', {username => 'Ahmed'}),
    1,
    'TEST 7: Dancer2::Plugin::FormValidator::Validator::Alpha: valid',
);

# TEST 8.
## Check Dancer2::Plugin::FormValidator::Validators::AlphaNum.

$validator = Dancer2::Plugin::FormValidator::Validator::AlphaNum->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 8: Dancer2::Plugin::FormValidator::Validator::AlphaNum messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 8: Dancer2::Plugin::FormValidator::Validator::AlphaNum stop_on_fail',
);

isnt(
    $validator->validate('username', {username => 'Ahмед23-'}),
    1,
    'TEST 8: Dancer2::Plugin::FormValidator::Validator::AlphaNum: not valid',
);

is(
    $validator->validate('username', {username => 'Ahмед_23'}),
    1,
    'TEST 8: Dancer2::Plugin::FormValidator::Validator::AlphaNum: valid',
);

# TEST 9.
## Check Dancer2::Plugin::FormValidator::Validators::Integer.

$validator = Dancer2::Plugin::FormValidator::Validator::Integer->new;

is_deeply(
    ref $validator->message,
    'HASH',
    'TEST 9: Dancer2::Plugin::FormValidator::Validator::Integer messages hash'
);

is(
    $validator->stop_on_fail,
    0,
    'TEST 9: Dancer2::Plugin::FormValidator::Validator::Integer stop_on_fail',
);

isnt(
    $validator->validate('age', {age => '2a3'}),
    1,
    'TEST 9: Dancer2::Plugin::FormValidator::Validator::Integer: not valid',
);

isnt(
    $validator->validate('age', {age => '23.4'}),
    1,
    'TEST 9: Dancer2::Plugin::FormValidator::Validator::Integer: not valid',
);

is(
    $validator->validate('age', {age => '23'}),
    1,
    'TEST 9: Dancer2::Plugin::FormValidator::Validator::Integer: valid',
);
