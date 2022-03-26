package Dancer2::Plugin::FormValidator;

use Data::FormValidator;
use Moo;
use Types::Standard qw(HashRef);
# use Dancer2::Plugin;

our $VERSION = '0.1';

has validator => (
    is       => 'ro',
    isa      => sub {
        my $object = shift;
        my $role = 'Dancer2::Plugin::FormValidator::Role::Validator';

        if (not $object->does($role)) {
            my $name = $object->meta->name;
            Carp::croak "$name should implement $role\n";
        }
    },
    required => 1,
);

has input => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has profile => (
    is       => 'rwp',
    isa      => HashRef,
    lazy     => 1,
    builder  => sub {
        my $self = shift;

        $self->_set_profile($self->validator->profile);
    }
);

sub validate {
    my $self = shift;

    my $results = Data::FormValidator->check(
        $self->input,
        $self->profile,
    );
}

1;
