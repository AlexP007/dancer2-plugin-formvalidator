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

        if ($validator_profile->does('Dancer2::Plugin::FormValidator::Role::HasMessages')) {
            my $validator_msg_errors = $validator_profile->messages;
            if (ref $validator_msg_errors eq 'HASH') {
                for my $item (@{ $invalid }) {
                    if (my $value = $validator_msg_errors->{$item}) {
                        $messages->{$item} = sprintf(
                            $value,
                            $ucfirst ? ucfirst($item) : $item,
                        );
                    }
                }
            }
        }
        else {
            for my $item (@{ $invalid }) {
                my ($field, $validator_name) = @$item;

                my $validator = $self->registry->get($validator_name);

                $messages->add(
                    $field,
                    sprintf(
                        $validator->message->{$language},
                        $ucfirst ? ucfirst($field) : $field,
                    )
                );
            }
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

        for my $validator (@validators) {
            if (not $self->_validate_field($field, $validator)) {
                push @invalid, [ $field, $validator ];
                $is_valid = 0;
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

sub _validate_field {
    my ($self, $field, $validator_name) = @_;

    my $validator = $self->registry->get($validator_name);

    return $validator->validate($field, $self->input);
}

1;
