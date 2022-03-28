package Dancer2::Plugin::FormValidator::Config;

use Moo;
use Types::Standard qw(HashRef Bool Str Undef);
use Types::Common::String qw(NonEmptyStr);
use namespace::clean;

has config => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has session => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has session_namespace => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

has messages => (
    is        => 'ro',
    isa       => HashRef,
    predicate => 1,
);

has messages_missing => (
    is       => 'ro',
    isa      => Undef | NonEmptyStr,
    lazy     => 1,
    builder  => sub {
        my $self = shift;
        return $self->has_messages ? $self->messages->{missing} : '%s is missing.';
    }
);

has messages_invalid => (
    is       => 'ro',
    isa      => Undef | NonEmptyStr,
    lazy     => 1,
    builder  => sub {
        my $self = shift;
        return $self->has_messages ? $self->messages->{invalid} : '%s is invalid.';
    }
);

has messages_ucfirst => (
    is       => 'ro',
    isa      => Undef | NonEmptyStr,
    lazy     => 1,
    builder  => sub {
        my $self = shift;
        return $self->has_messages ? $self->messages->{ucfirst} : 1;
    }
);

sub BUILDARGS {
    my ($self, %args) = @_;

    if (my $config = $args{config}) {
        $args{session} = $config->{session};

        if (my $messages = $config->{messages}) {
            $args{messages} = $messages;
        }

        if (my $session = $args{session}) {
            $args{session_namespace} = $session->{namespace};
        }
    }

    return \%args;
}

1;
