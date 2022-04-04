package Dancer2::Plugin::FormValidator::Validator::Same;

use Moo;
use utf8;
use namespace::clean;

with 'Dancer2::Plugin::FormValidator::Role::Validator';

sub message {
    return {
        en => '%s must be the same as %s',
        ru => '%s должно совпадать со значением %s',
        de => '%s muss identisch mit %s sein',
    };
}

sub validate {
    my ($self, $field, $input, $field2) = @_;

    if (exists $input->{$field}) {
        if (exists $input->{$field2}) {
            return $self->_is_same_as($input->{$field}, $input->{$field2});
        }
        else {
            return 0;
        }
    }

    return 1;
}

sub _is_same_as {
    my ($self, $value1, $value2) = @_;

    if (defined $value1 and defined $value2) {
        # This validator compare only strings.
        if (ref $value1 eq 'ARRAY' or ref $value2 eq 'ARRAY') {
            return 0;
        }
        else {
            return $value1 eq $value2;
        }
    }

    return 0;
}

1;
