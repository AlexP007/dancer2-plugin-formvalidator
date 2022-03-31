package Dancer2::Plugin::FormValidator::Registry;

use Moo;
use Carp;
use namespace::clean;

my %validators;

sub validator {
    my ($self, $validator_name) = @_;

    if (defined %validators{$validator_name}) {
        return %validators{$validator_name};
    }

    if (my $class = $self->_validators->{$validator_name}) {
        require $class;

        my $validator = $class->new;
        %validators{$validator_name} = $validator;

        return $validator;
    }

    Carp::croak("$validator_name is not defined\n");
}

sub _validators {
    return {
        required  => 'Dancer2::Plugin::FormValidator::Validators::Required',
        email     => 'Dancer2::Plugin::FormValidator::Validators::Email',
        email_dns => 'Dancer2::Plugin::FormValidator::Validators::EmailDns',
    };
}

1;
