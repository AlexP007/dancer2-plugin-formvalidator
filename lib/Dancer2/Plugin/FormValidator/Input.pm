package Dancer2::Plugin::FormValidator::Input;

use strict;
use warnings;

use Moo;
use Storable qw(dclone);
use Hash::Util qw(lock_hashref);
use Types::Standard qw(HashRef);
use namespace::clean;

### Input ###
# Class to isolate and manipulate input HashRef.

has _input => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
    init_arg => 'input',
);

sub BUILDARGS {
    my ($self, %args) = @_;

    if (my $input = $args{input}) {
        $args{input} = $self->_clone_and_lock_input($input);
    }

    return \%args;
}

sub get {
    my ($self, $field) = @_;

    return $self->_input->{$field};
}

# Field exists, defined and not empty string.
sub has {
    my ($self, $field) = @_;

    my $input = $self->_input;

    return exists  $input->{$field}
        && defined $input->{$field}
        && '' ne   $input->{$field};
}

# Create locked copy.
sub _clone_and_lock_input {
    # Copy input to work with isolated HashRef.
    my $input = dclone($_[1]);

    # Lock input to prevent accidental modifying.
    return lock_hashref($input);
}

1;
