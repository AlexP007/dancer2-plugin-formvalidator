package Dancer2::Plugin::FormValidator;

use Data::FormValidator;
use Moo;
use Types::Standard qw(HashRef);
use Dancer2::Plugin::FormValidator::Result;
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

        return;
    },
    required => 1,
);

has input => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has profile => (
    is       => 'ro',
    isa      => HashRef,
    lazy     => 1,
    builder  => sub {
        return shift->validator->profile;
    }
);

sub validate {
    my $self = shift;

    my $results = Data::FormValidator->check(
        $self->input,
        $self->profile,
    );

    my $result = Dancer2::Plugin::FormValidator::Result->new(
        input   => $self->input,
        results => $results,
    );

    return $result;
}

1;
