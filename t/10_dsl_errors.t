use strict;
use warnings;
use Test::More tests => 1;

package Validator {
    use Moo;

    with 'Dancer2::Plugin::FormValidator::Role::Profile';

    sub profile {
        return {
            email => [qw(required email)],
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
        if (not validate(Validator->new)) {
            to_json errors;
        }
    };
}

use Plack::Test;
use HTTP::Request::Common;

my $app    = Plack::Test->create(App->to_app);
my $result = $app->request(POST '/', [email => 'alexp.cpan.org']);

is(
    $result->content,
    '{"email":["Email is not a valid email"]}',
    'Check dsl: errors'
);
