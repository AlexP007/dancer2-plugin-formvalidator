use strict;
use warnings;
use utf8::all;
use Test::More tests => 2;

use Dancer2::Plugin::FormValidator::Config;
use Dancer2::Plugin::FormValidator::Registry;
use Dancer2::Plugin::FormValidator::Processor;

package Validator {
    use Moo;
    use Data::FormValidator::Constraints qw(:closures);

    with 'Dancer2::Plugin::FormValidator::Role::HasProfileMessages';

    sub profile {
        return {
            name  => [qw(required)],
            email => [qw(required email)],
        };
    };

    sub messages {
        return {
            required => {
                en => '%s is needed',
                ru => '%s это нужно',
            },
            email    => {
                en => '%s please use valid email',
                ru => '%s пожалуйста укажи правильную почту',
            }
        }
    }
}

my $config = Dancer2::Plugin::FormValidator::Config->new(
    config => {
        session  => {
            namespace => '_form_validator'
        },
        language => 'en',
    },
);

my $validator = Validator->new;
my $registry  = Dancer2::Plugin::FormValidator::Registry->new;
my $input = {
    email => 'alexсpan.org',
};

my $processor = Dancer2::Plugin::FormValidator::Processor->new(
    input             => $input,
    registry          => $registry,
    config            => $config,
    validator_profile => $validator,
);


# TEST 1.
## Check user defined messages(en) from validator class.

is_deeply(
    $processor->result->messages,
    {
        'name' => [
            'Name is needed'
        ],
        'email' => [
            'Email please use valid email'
        ]
    },
    'TEST 1: Check user defined messages(en) from validator class'
);

# TEST 2.
## Check user defined messages(ru) from validator class.

$config->language('ru');

is_deeply(
    $processor->result->messages,
    {
        'name' => [
            'Name это нужно'
        ],
        'email' => [
            'Email пожалуйста укажи правильную почту'
        ]
    },
    'TEST 1: Check user defined messages(ru) from validator class'
);
