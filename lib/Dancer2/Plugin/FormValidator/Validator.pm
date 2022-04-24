package Dancer2::Plugin::FormValidator::Validator;

use Moo;
use Storable qw(dclone);
use Hash::Util qw(lock_hashref);
use Dancer2::Plugin::FormValidator::Registry;
use Dancer2::Plugin::FormValidator::Processor;
use Types::Standard qw(InstanceOf ConsumerOf HashRef ArrayRef);
use namespace::clean;

has config => (
    is       => 'ro',
    isa      => InstanceOf['Dancer2::Plugin::FormValidator::Config'],
    required => 1,
);

has extensions => (
    is        => 'ro',
    isa       => ArrayRef[ConsumerOf['Dancer2::Plugin::FormValidator::Role::Extension']],
    predicate => 1,
);

has input => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has validator_profile => (
    is       => 'ro',
    isa      => ConsumerOf['Dancer2::Plugin::FormValidator::Role::Profile'],
    required => 1,
);

sub validate {
    my $self = shift;

    my $processor = Dancer2::Plugin::FormValidator::Processor->new(
        input             => $self->_input,
        config            => $self->config,
        registry          => $self->_registry,
        validator_profile => $self->validator_profile,
    );

    return $processor->result;
}

sub _input {
    my $self = shift;
    return $self->_clone_and_lock_input($self->input);
}

sub _clone_and_lock_input {
    # Copy input to work with isolated HashRef.
    my $input = dclone($_[1]);

    # Lock input to prevent accidental modifying.
    return lock_hashref($input);
}

sub _registry {
    return Dancer2::Plugin::FormValidator::Registry->new(
        extensions => shift->extensions,
    );
}

1;