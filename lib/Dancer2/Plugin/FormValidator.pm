package Dancer2::Plugin::FormValidator;

use Data::FormValidator;
use Moo;
use Data::Dumper;
# use Dancer2::Plugin;

our $VERSION = '0.1';

has validator => (
    is  => 'ro',
    isa => sub {
        my $object = shift;
        my $role   = 'Dancer2::Plugin::FormValidator::Role::Validator';

        if (not $object->does($role)) {
            my $name = $object->meta->name;
            Carp::croak "$name should implement $role\n";
        }
    },
);

1;
