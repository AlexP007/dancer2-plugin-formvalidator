package Dancer2::Plugin::FormValidator::Registry;

use Moo;
use Carp;
use Module::Load;
use namespace::clean;

my %validators;

sub get {
    my ($self, $name) = @_;

    if (defined $validators{$name}) {
        return $validators{$name};
    }

    if (my $class = $self->_validators->{$name}) {
        autoload $class;

        my $role      = 'Dancer2::Plugin::FormValidator::Role::Validator';
        my $validator = $class->new;

        if (not $validator->does($role)) {
            Carp::croak "Validator: $class should implement $role\n";
        }

        $validators{$name} = $validator;

        return $validator;
    }

    Carp::croak("$name is not defined\n");
}

sub _validators {
    return {
        required  => 'Dancer2::Plugin::FormValidator::Validators::Required',
        email     => 'Dancer2::Plugin::FormValidator::Validators::Email',
        email_dns => 'Dancer2::Plugin::FormValidator::Validators::EmailDns',
    };
}

1;
