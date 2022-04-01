package Dancer2::Plugin::FormValidator::Validators::Required;

use Moo;

with 'Dancer2::Plugin::FormValidator::Role::Validator';

sub message {
    return {
        en => '%s is required',
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
