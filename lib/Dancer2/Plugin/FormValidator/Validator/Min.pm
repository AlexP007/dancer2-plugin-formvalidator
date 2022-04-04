package Dancer2::Plugin::FormValidator::Validator::Min;

use Moo;
use utf8;
use Scalar::Util qw(looks_like_number);
use namespace::clean;

with 'Dancer2::Plugin::FormValidator::Role::Validator';

sub message {
    return {
        en => '%s must be at least %s',
        ru => '%s должно быть не меньше %s',
        de => '%s muss größer als %s sein',
    };
}

sub validate {
    my ($self, $field, $input, $min) = @_;

    if (exists $input->{$field}) {
        my $maybe_num = $input->{$field};

        if (looks_like_number($maybe_num)) {
            return $maybe_num >= $min;
        }
        else {
            return 0;
        }
    }

    return 1;
}

1;
