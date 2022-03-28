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
    is       => 'ro',
    isa      => Undef | HashRef,
    lazy     => 1,
    builder  => sub {
        return shift->config->{messages};
    }
);


has messages_missing => (
    is       => 'ro',
    isa      => Undef | NonEmptyStr,
    lazy     => 1,
    builder  => sub {
        return shift->messages->{missing};
    }
);

has messages_invalid => (
    is       => 'ro',
    isa      => Undef | NonEmptyStr,
    lazy     => 1,
    builder  => sub {
        return shift->messages->{invalid};
    }
);

has messages_ucfirst => (
    is       => 'ro',
    isa      => Undef | NonEmptyStr,
    lazy     => 1,
    builder  => sub {
        return shift->messages->{ucfirst};
    }
);

sub BUILDARGS {
    my ($self, %args) = @_;

    if (my $config = $args{config}) {
        $args{session} = $config->{session};

        if (my $session = $args{session}) {
            $args{session_namespace} = $session->{namespace};
        }
    }

    return \%args;
}

1;
