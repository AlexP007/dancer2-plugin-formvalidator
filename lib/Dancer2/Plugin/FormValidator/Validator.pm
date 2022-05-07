package Dancer2::Plugin::FormValidator::Validator;

use strict;
use warnings;

use Moo;
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
    is       => 'ro',
    isa      => ArrayRef[ConsumerOf['Dancer2::Plugin::FormValidator::Role::Extension']],
    required => 1,
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

has registry => (
    is       => 'ro',
    default  => sub {
        return Dancer2::Plugin::FormValidator::Registry->new(
            extensions => $_[0]->extensions,
        );
    }
);

sub validate {
    my ($self) = @_;

    my $processor = Dancer2::Plugin::FormValidator::Processor->new(
        input             => $self->input,
        config            => $self->config,
        registry          => $self->registry,
        validator_profile => $self->validator_profile,
    );

    return $processor->result;
}

1;
