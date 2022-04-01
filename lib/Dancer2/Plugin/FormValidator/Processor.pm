package Dancer2::Plugin::FormValidator::Processor;

use Moo;
use Hash::Util qw(lock_hashref);
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

has validator => (
    is       => 'ro',
    isa      => ConsumerOf['Dancer2::Plugin::FormValidator::Role::HasProfile'],
    required => 1,
);

sub BUILDARGS {
    my ($self, %args) = @_;

    if (my $input = $args{input}) {
        $args{input} = lock_hashref($input);
    }

    return \%args;
}

sub result {
    my $self    = shift;

    my ($success, $valid, $invalid) = $self->_validate;

    return ($success, $valid, $invalid);

    # my $messages;
    #
    # if ($success != 1) {
    #     $messages     = {};
    #     my $config    = $self->config;
    #     my $validator = $self->validator;
    #
    #     my $messages_invalid = $config->messages_invalid;
    #     my $ucfirst          = $config->messages_ucfirst;
    #
    #     if ($validator->does('Dancer2::Plugin::FormValidator::Role::HasMessages')) {
    #         my $validator_msg_errors = $validator->messages;
    #         if (ref $validator_msg_errors eq 'HASH') {
    #             for my $item (@invalid) {
    #                 if (my $value = $validator_msg_errors->{$item}) {
    #                     $messages->{$item} = sprintf(
    #                         $value,
    #                         $ucfirst ? ucfirst($item) : $item,
    #                     );
    #                 }
    #             }
    #         }
    #         else {
    #             $messages = $validator_msg_errors;
    #         }
    #     }
    #     else {
    #         for my $item (@invalid) {
    #             $messages->{$item} = sprintf(
    #                 $messages_invalid,
    #                 $ucfirst ? ucfirst($item) : $item,
    #             );
    #         }
    #     }
    # }

    # return Dancer2::Plugin::FormValidator::Result->new(
    #     success  => $success,
    #     valid    => $valid,
    #     invalid  => \@invalid,
    #     messages => $messages,
    # );
}

sub _validate {
    my $self    = shift;
    my %input   = %{ $self->input };
    my $profile = $self->validator->profile;
    my $is_valid;
    my @valid;
    my @invalid;

    for my $field (keys %input) {
        $is_valid = 1;
        my @validators = @{ $profile->{$field} };
        print "field: $field\n";
        for my $validator (@validators) {
            print "validator: $validator\n";
            if (not $self->_validate_field($field, $validator)) {
                push @invalid, [ $field, $validator ];
                $is_valid = 0;
            }
        }

        if ($is_valid == 1) {
            push @valid, $field;
        }
    }

    return ($is_valid, \@valid, \@invalid)
}

sub _validate_field {
    my ($self, $field, $validator_name) = @_;

    my $validator = $self->registry->get($validator_name);

    return $validator->validate($field, $self->input);
}

1;
