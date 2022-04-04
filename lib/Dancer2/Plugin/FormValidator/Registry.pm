package Dancer2::Plugin::FormValidator::Registry;

use Moo;
use Carp;
use Module::Load;
use Types::Standard qw(ConsumerOf ArrayRef HashRef);
use namespace::clean;

my %validators;

has extensions => (
    is        => 'ro',
    isa       => ArrayRef[ConsumerOf['Dancer2::Plugin::FormValidator::Role::Extension']],
    predicate => 1,
);

has validators => (
    is        => 'ro',
    isa       => HashRef,
    required  => 1,
    builder   => sub {
        my $self       = shift;
        my $validators = $self->_validators;

        if ($self->has_extensions) {
            for my $extension (@{ $self->extensions }) {
                $validators = {%{ $validators }, %{ $extension->validators }};
            };
        }

        return $validators;
    }
);

sub get {
    my ($self, $name) = @_;

    if (defined $validators{$name}) {
        return $validators{$name};
    }

    if (my $class = $self->validators->{$name}) {
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
        alpha     => 'Dancer2::Plugin::FormValidator::Validator::Alpha',
        alpha_num => 'Dancer2::Plugin::FormValidator::Validator::AlphaNum',
        enum      => 'Dancer2::Plugin::FormValidator::Validator::Enum',
        email     => 'Dancer2::Plugin::FormValidator::Validator::Email',
        email_dns => 'Dancer2::Plugin::FormValidator::Validator::EmailDns',
        integer   => 'Dancer2::Plugin::FormValidator::Validator::Integer',
        max       => 'Dancer2::Plugin::FormValidator::Validator::Max',
        min       => 'Dancer2::Plugin::FormValidator::Validator::Min',
        numeric   => 'Dancer2::Plugin::FormValidator::Validator::Numeric',
        required  => 'Dancer2::Plugin::FormValidator::Validator::Required',
        same      => 'Dancer2::Plugin::FormValidator::Validator::Same',
    };
}

1;
