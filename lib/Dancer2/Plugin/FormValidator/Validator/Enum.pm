package Dancer2::Plugin::FormValidator::Validator::Enum;

use Moo;
use utf8;
use List::Util qw(first);
use namespace::clean;

with 'Dancer2::Plugin::FormValidator::Role::Validator';

sub message {
    return {
        en => '%s contains invalid value',
        ru => '%s содержит неверное значение',
        de => '%s enthält einen ungültigen Wert',
    };
}

sub validate {
    my ($self, $field, $input, @enum) = @_;

    if (exists $input->{$field}) {
        return $self->_is_enum($input->{$field}, @enum);
    }

    return 1;
}

sub _is_enum {
    my ($self, $value1, @enum) = @_;

    if (defined $value1) {
        my $first = first {$_ eq $value1} @enum;

        return defined $first ? 1 : 0;
    }

    return 0;
}

1;
