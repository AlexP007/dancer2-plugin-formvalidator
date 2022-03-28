package Dancer2::Plugin::FormValidator::Processor;

use Moo;
use Dancer2::Plugin::FormValidator::Result;
use Data::FormValidator::Results;
use Types::Standard qw(InstanceOf);
use namespace::clean;

has results => (
    is       => 'ro',
    isa      => InstanceOf['Data::FormValidator::Results'],
    required => 1,
);

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

sub result {
    my $self      = shift;
    my $validator = $self->validator;

    my $success   = $self->results->success;
    my $valid     = $self->results->valid;
    my @missing   = $self->results->missing;
    my @invalid   = $self->results->invalid;

    my $messages;

    if (
        $success != 1 and
        $validator->does('Dancer2::Plugin::FormValidator::Role::HasMessages')
    ) {
        my $validator_msg_errors = $validator->messages;
        if (ref $validator_msg_errors eq 'HASH') {
            $messages = {};

            for my $item (@missing) {
                $messages->{$item} = sprintf('%s is missing.', ucfirst($item));
            }

            for my $item (@invalid) {
                if (my $value = $validator_msg_errors->{$item}) {
                    $messages->{$item} = sprintf($value, ucfirst($item));
                }
            }
        }
        else {
            $messages = $validator_msg_errors;
        }
    }

    return Dancer2::Plugin::FormValidator::Result->new(
        success  => $success,
        valid    => $valid,
        missing  => \@missing,
        invalid  => \@invalid,
        messages => $messages,
    );
}

1;
