package Dancer2::Plugin::FormValidator::Processor;

use Moo;
use List::Util qw(uniqstr);
use Hash::MultiValue;
use Dancer2::Plugin::FormValidator::Result;
use Types::Standard qw(InstanceOf ConsumerOf HashRef);
use namespace::clean;

has input => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has config => (
    is       => 'ro',
    isa      => InstanceOf['Dancer2::Plugin::FormValidator::Config'],
    required => 1,
);

has registry => (
    is       => 'ro',
    isa      => InstanceOf['Dancer2::Plugin::FormValidator::Registry'],
    required => 1,
);

has validator_profile => (
    is       => 'ro',
    isa      => ConsumerOf['Dancer2::Plugin::FormValidator::Role::HasProfile'],
    required => 1,
);

sub result {
    my $self     = shift;
    my $messages = Hash::MultiValue->new;

    my ($success, $valid, $invalid) = $self->_validate;

    if ($success != 1) {
        my $config            = $self->config;
        my $ucfirst           = $config->messages_ucfirst;
        my $language          = $config->language;
        my $validator_profile = $self->validator_profile;

        for my $item (@{ $invalid }) {
            my ($field, $validator_name) = @$item;

            my $validator = $self->registry->get($validator_name);
            my $message   = $self->config->messages_validators->{$validator_name} || $validator->message;

            if ($validator_profile->does('Dancer2::Plugin::FormValidator::Role::HasMessages')) {
                my $validator_messages = $validator_profile->messages;
                if (ref $validator_messages eq 'HASH') {
                    $message = $validator_messages->{$validator_name} || $message;
                }
                else {
                    Carp::croak("Messages should be a HashRef\n")
                }
            }

            $messages->add(
                $field,
                sprintf(
                    $message->{$language},
                    $ucfirst ? ucfirst($field) : $field,
                )
            );
        }
    }

    # Flatten $invalid array ref and leave only unique fields.
    my @invalid = uniqstr map { $_->[0] } @ { $invalid };

    return Dancer2::Plugin::FormValidator::Result->new(
        success  => $success,
        valid    => $valid,
        invalid  => \@invalid,
        messages => $messages,
    );
}

sub _validate {
    my $self    = shift;
    my $success = 0;
    my %profile = %{ $self->validator_profile->profile };
    my $is_valid;
    my @valid;
    my @invalid;

    for my $field (keys %profile) {
        $is_valid = 1;
        my @validators = @{ $profile{$field} };

        for my $validator_name (@validators) {
            my $validator = $self->registry->get($validator_name);

            if (not $validator->validate($field, $self->input)) {
                push @invalid, [ $field, $validator_name ];
                $is_valid = 0;
            }

            if (!$is_valid && $validator->stop_on_fail) {
                last;
            }
        }

        if ($is_valid == 1) {
            push @valid, $field;
        }
    }

    if (not @invalid) {
        $success = 1;
    }

    return ($success, \@valid, \@invalid)
}

1;
