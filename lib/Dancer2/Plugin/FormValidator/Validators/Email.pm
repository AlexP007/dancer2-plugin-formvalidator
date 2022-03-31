package Dancer2::Plugin::FormValidator::Validators::Email;

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
    return $self->_is_valid_email($input->{$field});
}

sub _is_valid_email {
    if (my $valid_email = Email::Valid->address($_[1])) {
        return $_[1] eq $valid_email;
    }

    return 0;
}

1;
