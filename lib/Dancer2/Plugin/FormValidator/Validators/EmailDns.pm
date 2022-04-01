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
    my ($self, $field, $input) = @_;

    if (exists $input->{$field}) {
        return $self->_is_valid_email_and_dns($input->{$field});
    }

    return 0;
}

sub _is_valid_email_and_dns {
    if (my $valid_email = Email::Valid->address(-address => $_[1], -mxcheck => 1 )) {
        return $_[1] eq $valid_email;
    }

    return 0;
}

1;
