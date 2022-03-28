use strict;
use warnings;
use Test::More tests => 1;

use Dancer2;

BEGIN {
    set plugins => {
        FormValidator => {
            session  => {
                namespace => '_form_validator'
            },
            messages => {
                missing => '<span>%s is missing.</span>',
                invalid => '<span>%s is invalid.</span>',
                ucfirst => 0,
            },
        },
    };
}

package Validator {
    use Moo;
    use Data::FormValidator::Constraints qw(:closures);

    with 'Dancer2::Plugin::FormValidator::Role::HasProfile';

    sub profile {
        return {
            required => [qw(name email)],
            constraint_methods => {
                email => email,
            },
        };
    };
}

use Dancer2::Plugin::FormValidator;

my $result = validate {
    email => 'alexpan.org',
}, Validator->new;


is_deeply(
    $result->messages,
    {
        'name'  => '<span>name is missing.</span>',
        'email' => '<span>email is invalid.</span>'
    },
    'Check messages form dancer config'
);
