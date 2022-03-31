package Dancer2::Plugin::FormValidator::Validators::EmailDns;

use Moo;
use Email::Valid;
use namespace::clean;

with 'Dancer2::Plugin::FormValidator::Role::Validator';

sub message {
    return {
        en => '%s is not a valid email',
    };
}

sub validate {
    my ($field, $input) = @_;
    my $email = $input->{$field};

    return $email eq Email::Valid->address(-address => $email, -mxcheck => 1 );
}

1;