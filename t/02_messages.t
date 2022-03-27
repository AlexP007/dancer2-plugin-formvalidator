use strict;
use warnings;
use Test::More tests => 2;

use Dancer2::Plugin::FormValidator::Processor;
use Data::FormValidator;

package Validator {
    use Moo;
    use Data::FormValidator::Constraints qw(:closures);

    with 'Dancer2::Plugin::FormValidator::Role::Validator',
         'Dancer2::Plugin::FormValidator::Role::HasMessages';

    sub profile {
        return {
            required => [qw(name email)],
            constraint_methods => {
                email => email,
            },
        };
    };

    sub msgs {
        return {
            success => 'All is good',
            errors  => {
                'email' => '%s should be a valid email.'
            },
        };
    }
}

my $validator = Validator->new;
my $result;
my $results;
my $processor;

# TEST 1.
## Check msg_success.

$results = Data::FormValidator->check(
    {
        name  => 'Alex',
        email => 'alexpan@cpan.org',
    },
    $validator->profile,
);

$processor = Dancer2::Plugin::FormValidator::Processor->new(
    results   => $results,
    validator => $validator,
);

$result = $processor->result;

is('All is good', $result->msg_success, 'TEST 1: Check msg_success');

# TEST 2.
## Check msg_errors.

$results = Data::FormValidator->check(
    {
        email => 'alexpan.org',
    },
    $validator->profile,
);

$processor = Dancer2::Plugin::FormValidator::Processor->new(
    results   => $results,
    validator => $validator,
);

$result = $processor->result;

is_deeply(
    {
        'name'  => 'Name is missing.',
        'email' => 'Email should be a valid email.'
    },
    $result->msg_errors,
    'TEST 2: Check msg_errors'
);
