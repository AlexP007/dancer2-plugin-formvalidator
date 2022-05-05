use strict;
use warnings;

use FindBin;
use Test::More tests => 1;

require "$FindBin::Bin/lib/validator.pl";

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
        to_json validate profile => Validator->new(profile_hash =>
            {
                email => [qw(required email)],
            }
        );
    };
}

use Plack::Test;
use HTTP::Request::Common;

my $app    = Plack::Test->create(App->to_app);
my $result = $app->request(POST '/', [email => 'alexp@cpan.org', name => 'hacker']);

is(
    $result->content,
    '{"email":"alexp@cpan.org"}',
    'Check dsl: validate',
);
