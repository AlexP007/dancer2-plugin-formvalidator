package Dancer2::Plugin::FormValidator::Validators::Required;

use Moo;
use utf8;
use namespace::clean;

with 'Dancer2::Plugin::FormValidator::Role::Validator';

sub message {
    return {
        en => '%s is required',
        ru => '%s обязательно для заполнения',
    };
}

around 'stop_on_fail' => sub {
    return 1;
};

sub validate {
    my ($self, $field, $input) = @_;

    return exists $input->{$field};
}

1;
