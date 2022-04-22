use strict;
use warnings;
use Test::More tests => 1;
use JSON::MaybeXS;

package Validator {
    use Moo;

    with 'Dancer2::Plugin::FormValidator::Role::Profile';

    sub profile {
        return {
            password     => [qw(required)],
            password_cnf => [qw(required same:password)],
            role         => [qw(required enum:user,agent)]
        };
    };
}

package App {
    use Dancer2;

    BEGIN {
        set plugins => {
            FormValidator => {
                session => {
                    namespace => '_form_validator'
                },
            },
        };
    }

    use Dancer2::Plugin::FormValidator;

    post '/' => sub {
        if (my $validated = validate profile => Validator->new) {
            to_json {
                'validated'          => $validated,
                'validated_from_dsl' => validated,
            };
        }
    };
}

use Plack::Test;
use HTTP::Request::Common;

my $app    = Plack::Test->create(App->to_app);
my $result = $app->request(POST '/', [password => 'pass1', password_cnf => 'pass1', role => 'agent']);

my $content = decode_json $result->content;

is_deeply(
    $content->{validated},
    $content->{validated_from_dsl},
    'Check validated result',
);
