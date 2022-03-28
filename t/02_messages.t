use strict;
use warnings;
use Test::More tests => 2;

use Dancer2::Plugin::FormValidator::Processor;
use Data::FormValidator;

package Validator {
    use Moo;
    use Data::FormValidator::Constraints qw(:closures);

    with 'Dancer2::Plugin::FormValidator::Role::HasProfile',
         'Dancer2::Plugin::FormValidator::Role::HasMessages';

    sub profile {
        return {
            required => [qw(name email)],
            constraint_methods => {
                email => email,
            },
        };
    };

    sub messages {
        return 'Error occurred';
    }
}

my $validator = Validator->new;
my $result;
my $results;
my $processor;

# TEST 1.
## Check msg_errors string.

$results = Data::FormValidator->check(
    {
        email => 'alexpan@cpan.org',
    },
    $validator->profile,
);

$processor = Dancer2::Plugin::FormValidator::Processor->new(
    results   => $results,
    validator => $validator,
);

$result = $processor->result;

is('Error occurred', $result->messages, 'TEST 1: Check msg_errors string');

# TEST 2.
## Check msg_errors hash.

package Validator2 {
    use Moo;
    use Data::FormValidator::Constraints qw(:closures);

    with 'Dancer2::Plugin::FormValidator::Role::HasProfile',
        'Dancer2::Plugin::FormValidator::Role::HasMessages';

    sub profile {
        return {
            required => [qw(name email)],
            constraint_methods => {
                email => email,
            },
        };
    };

    sub messages {
        return {
            'email' => '%s should be a valid email.',
        };
    }
}

$validator = Validator2->new;

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
    $result->messages,
    'TEST 2: Check msg_errors hash'
);
