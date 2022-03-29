package Dancer2::Plugin::FormValidator;

use Dancer2::Plugin;
use Dancer2::Plugin::FormValidator::Config;
use Dancer2::Plugin::FormValidator::Processor;
use Data::FormValidator;
use Types::Standard qw(InstanceOf HashRef);

our $VERSION = '0.1';

plugin_keywords qw(validate validate_form);

has config_obj => (
    is       => 'ro',
    isa      => InstanceOf['Dancer2::Plugin::FormValidator::Config'],
    required => 1,
    builder  => sub {
        return Dancer2::Plugin::FormValidator::Config->new(
            config => shift->config,
        );
    }
);

sub validate_form {
    my ($self, $form) = @_;

    if (my $validator = $self->config_obj->form($form)) {
        my $input  = $self->dsl->body_parameters->as_hashref;
        my $result = $self->validate($input, $validator->new);

        return $result->success ? $result->valid : undef;
    }
    else {
        Carp::croak "Validator for $form is not defined\n";
    }
}

sub validate {
    my ($self, $input, $validator) = @_;

    if (ref $input ne 'HASH') {
        Carp::croak "Input data should be a hash reference\n";
    }

    my $role = 'Dancer2::Plugin::FormValidator::Role::HasProfile';
    if (not $validator->does($role)) {
        my $name = $validator->meta->name;
        Carp::croak "$name should implement $role\n";
    }

    my $processor = Dancer2::Plugin::FormValidator::Processor->new(
        config    => $self->config_obj,
        validator => $validator,
        results   => Data::FormValidator->check($input, $validator->profile),
    );

    return $processor->result;
}

1;
