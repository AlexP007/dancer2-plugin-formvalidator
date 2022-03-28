package Dancer2::Plugin::FormValidator;

use Dancer2::Plugin;
use Dancer2::Plugin::FormValidator::Config;
use Dancer2::Plugin::FormValidator::Processor;
use Data::FormValidator;
use Types::Standard qw(InstanceOf HashRef);

our $VERSION = '0.1';

plugin_keywords qw(validate);

has config => (
    is       => 'ro',
    isa      => InstanceOf['Dancer2::Plugin::FormValidator::Config'],
    required => 1,
    builder  => sub {
        return Dancer2::Plugin::FormValidator::Config->new(
            config => shift->app->config->{plugins}->{FormValidator},
        );
    }
);

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
        config    => $self->config,
        validator => $validator,
        results   => Data::FormValidator->check($input, $validator->profile),
    );

    return $processor->result;
}

1;
