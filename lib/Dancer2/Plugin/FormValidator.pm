package Dancer2::Plugin::FormValidator;

use Moo;
use Dancer2::Plugin::FormValidator::Processor;
use Data::FormValidator;
use Types::Standard qw(HashRef);
# use Dancer2::Plugin;

our $VERSION = '0.1';

has validator => (
    is       => 'ro',
    isa      => sub {
        my $validator = shift;
        my $role = 'Dancer2::Plugin::FormValidator::Role::HasProfile';

        if (not $validator->does($role)) {
            my $name = $validator->meta->name;
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

    my $processor = Dancer2::Plugin::FormValidator::Processor->new(
        results   => $results,
        validator => $self->validator,
    );

    my $result = $processor->result;

    return $result;
}

1;
