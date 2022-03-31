package Dancer2::Plugin::FormValidator::Validators::Required;

use Moo;

with 'Dancer2::Plugin::FormValidator::Role::Validator';

sub message {
    return {
        en => '%s is required',
    };
}

sub validate {
    my ($field, $input) = @_;

    return exists $input->{$field};
}

1;
