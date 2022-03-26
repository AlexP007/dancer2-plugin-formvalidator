package Dancer2::Plugin::FormValidator::Result;

use Moo;
use Data::FormValidator::Results;
use Types::Standard qw(ArrayRef HashRef InstanceOf Bool);
use namespace::clean;

has input => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has results => (
    is       => 'ro',
    isa      => InstanceOf['Data::FormValidator::Results'],
    required => 1,
);

has success => (
    is       => 'ro',
    isa      => Bool,
    lazy     => 1,
    builder  => sub {
        return shift->results->success;
    }
);

has missing => (
    is       => 'ro',
    isa      => ArrayRef,
    lazy     => 1,
    builder  => sub {
        return [shift->results->missing];
    }
);

has invalid => (
    is       => 'ro',
    isa      => ArrayRef,
    lazy     => 1,
    builder  => sub {
        return [shift->results->invalid];
    }
);

has valid => (
    is       => 'ro',
    isa      => ArrayRef,
    lazy     => 1,
    builder  => sub {
        return [shift->results->valid];
    }
);

has validated => (
    is       => 'ro',
    isa      => HashRef,
    lazy     => 1,
    builder  => '_validated'
);

sub _validated {
    my $self = shift;
    my %result;

    for my $value (@{ $self->valid }) {
        $result{$value} = $self->input->{$value};
    }

    return \%result;
}

1;
