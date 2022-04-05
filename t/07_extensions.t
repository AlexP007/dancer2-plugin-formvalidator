use strict;
use warnings;
use utf8::all;
use Test::More tests => 1;

use Dancer2::Plugin::FormValidator::Config;
use Dancer2::Plugin::FormValidator::Registry;
use Dancer2::Plugin::FormValidator::Processor;

package Validator {
    use Moo;

    with 'Dancer2::Plugin::FormValidator::Role::Profile';

    sub profile {
        return {
            name   => [qw(restrict is_true)],
            accept => [qw(required is_true)],
            email  => [qw(required email)],
        };
    };
}

package IsTrue {
    use Moo;

    with 'Dancer2::Plugin::FormValidator::Role::Validator';

    sub message {
        return {
            en => '%s is not a true value',
        };
    }

    sub validate {
        my ($self, $field, $input) = @_;

        if (exists $input->{$field}) {
            if ($input->{$field} == 1) {
                return 1;
            }
            else {
                return 0;
            }
        }

        return 1;
    }
}

package Email {
    use Moo;

    with 'Dancer2::Plugin::FormValidator::Role::Validator';

    sub message {
        return {
            en => '%s is a message from extension email',
        };
    }

    sub validate {
        return 0;
    }
}

package Restrict {
    use Moo;

    with 'Dancer2::Plugin::FormValidator::Role::Validator';

    sub message {
        return {
            en => '%s is restricted',
        };
    }

    around 'stop_on_fail' => sub {
        return 1;
    };

    sub validate {
        my ($self, $field, $input) = @_;

        not (exists $input->{$field});
    }
}

package Extension {
    use Moo;

    with 'Dancer2::Plugin::FormValidator::Role::Extension';

    sub validators {
        return {
            is_true  => 'IsTrue',
            email    => 'Email',
            restrict => 'Restrict',
        }
    }
}

my $config = Dancer2::Plugin::FormValidator::Config->new(
    config => {
        session  => {
            namespace => '_form_validator'
        },
        messages => {
            language => 'en',
        }
    },
);

my $validator = Validator->new;
my $registry  = Dancer2::Plugin::FormValidator::Registry->new(
    extensions => [Extension->new],
);
my $input = {
    name   => 0,
    accept => 0,
    email  => 'alexсpan.org',
};

my $processor = Dancer2::Plugin::FormValidator::Processor->new(
    input             => $input,
    registry          => $registry,
    config            => $config,
    validator_profile => $validator,
);


# TEST 1.
## Check messages(en) from extensions validator.

is_deeply(
    $processor->result->messages,
    {
        'name' => [
            'Name is restricted'
        ],
        accept => [
            'Accept is not a true value'
        ],
        'email' => [
            'Email is a message from extension email'
        ]
    },
    'TEST 1: Check messages(en) from extensions validator'
);