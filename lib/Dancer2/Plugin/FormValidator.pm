package Dancer2::Plugin::FormValidator;

use 5.24.0;

use Dancer2::Plugin;
use Dancer2::Core::Hook;
use Dancer2::Plugin::FormValidator::Config;
use Dancer2::Plugin::FormValidator::Registry;
use Dancer2::Plugin::FormValidator::Processor;
use Storable qw(dclone);
use Hash::Util qw(lock_hashref);
use Module::Load;
use Types::Standard qw(InstanceOf HashRef);

our $VERSION = '0.71';

# Global var for saving last success validation valid input.
my $valid_input;

plugin_keywords qw(validate validated errors);

has config_obj => (
    is       => 'ro',
    isa      => InstanceOf['Dancer2::Plugin::FormValidator::Config'],
    required => 1,
    builder  => sub {
        return Dancer2::Plugin::FormValidator::Config->new(
            config => shift->config,
        );
    }
);

has plugin_deferred => (
    is       => 'ro',
    isa      => InstanceOf ['Dancer2::Plugin::Deferred'],
    required => 1,
    builder  => sub {
        return shift->app->with_plugin('Dancer2::Plugin::Deferred');
    }
);

has extensions => (
    is       => 'ro',
    isa      => HashRef,
    default  => sub {
        return shift->config->{extensions} // {},
    }
);

sub BUILD {
    my $self = shift;

    $self->app->add_hook(
        Dancer2::Core::Hook->new(
            name => 'before_template_render',
            code => sub {
                my $tokens = shift;
                my $errors = {};
                my $old    = {};

                if (my $deferred = $tokens->{deferred}->{$self->config_obj->session_namespace}) {
                    $errors = delete $deferred->{messages};
                    $old    = delete $deferred->{old};
                }

                $tokens->{errors} = $errors;
                $tokens->{old}    = $old;

                return;
            },
        )
    );
}

sub validate {
    my ($self, %params) = @_;

    # We need to unset value of this global var.
    $valid_input = undef;

    # Now works with arguments.
    my $profile = %params{profile};
    my $input   = %params{input} // $self->dsl->body_parameters->as_hashref_mixed;
    my $lang    = %params{lang};

    if (defined $lang) {
        $self->_validator_language($lang);
    }

    my $result = $self->_validate($input, $profile);

    if ($result->success) {
        $valid_input = $result->valid;
        return $valid_input;
    }

    return undef;
}

sub validated {
    my $valid    = $valid_input;
    $valid_input = undef;

    return $valid;
}

sub errors {
    return shift->_get_deferred->{messages};
}


sub _validator_language {
    shift->config_obj->language(shift);
    return;
}

sub _validate {
    my ($self, $input, $validator_profile) = @_;

    if (ref $input ne 'HASH') {
        Carp::croak "Input data should be a hash reference\n";
    }

    my $role = 'Dancer2::Plugin::FormValidator::Role::Profile';
    if (not $validator_profile->does($role)) {
        my $name = $validator_profile->meta->name;
        Carp::croak "$name should implement $role\n";
    }

    my $processor = Dancer2::Plugin::FormValidator::Processor->new(
        input             => $self->_clone_and_lock_input($input),
        config            => $self->config_obj,
        registry          => $self->_registry,
        validator_profile => $validator_profile,
    );

    my $result = $processor->result;

    if ($result->success != 1) {
        $self->plugin_deferred->deferred(
            $self->config_obj->session_namespace,
            {
                messages => $result->messages,
                old      => $input,
            },
        );
    }

    return $result;
}

sub _clone_and_lock_input {
    # Copy input to work with isolated HashRef.
    my $input = dclone($_[1]);

    # Lock input to prevent accidental modifying.
    return lock_hashref($input);
}

sub _registry {
    my $self = shift;

    # First build extensions.
    my @extensions = map
    {
        my $extension = $self->extensions->{$_}->{provider};
        autoload $extension;

        $extension->new(
            plugin => $self,
            config => $self->extensions->{$_},
        );
    }
        keys %{ $self->extensions };

    return Dancer2::Plugin::FormValidator::Registry->new(
        extensions => \@extensions,
    );
}

sub _get_deferred {
    my $self = shift;

    return $self->plugin_deferred->deferred($self->config_obj->session_namespace);
}

1;

__END__
# ABSTRACT: Dancer2 validation framework.

=pod

=encoding UTF-8

=head1 NAME

Dancer2::Plugin::FormValidator - neat and easy to start form validation plugin for Dancer2.

=head1 VERSION

version 0.71

=head1 SYNOPSIS

    use Dancer2::Plugin::FormValidator;

    package RegisterForm {
         use Moo;
         with 'Dancer2::Plugin::FormValidator::Role::Profile';

         sub profile {
            return {
                username     => [ qw(required alpha_num_ascii length_min:4 length_max:32) ],
                email        => [ qw(required email length_max:127) ],
                password     => [ qw(required length_max:40) ],
                password_cnf => [ qw(required same:password) ],
                confirm      => [ qw(required accepted) ],
            };
        };
    }

    post '/form' => sub {
        if (validate profile => RegisterForm->new) {
            my $valid_hash_ref = validated;

            save_user_input($valid_hash_ref);
            redirect '/success_page';
        }

        redirect '/form';
    };

=head1 DISCLAIMER

This is alpha version, not stable.

Interfaces may change in future:

=over 4

=item *
Roles: Dancer2::Plugin::FormValidator::Role::Extension, Dancer2::Plugin::FormValidator::Role::Validator.

=item *
Validators.

=back

Won't change:

=over 4

=item *
Dsl keywords.

=item *
Template tokens.

=item *
Roles: Dancer2::Plugin::FormValidator::Role::Profile, Dancer2::Plugin::FormValidator::Role::HasMessages, Dancer2::Plugin::FormValidator::Role::ProfileHasMessages.

=back

If you like it - add it to your bookmarks. I intend to complete the development by the summer 2022.

B<Have any ideas?> Find this project on github (repo ref is at the bottom).
Help is always welcome!

=head1 DESCRIPTION

This is micro-framework that provides validation in your Dancer2 application.
It consists of dsl's keywords: validate, validator_language, errors.
It has a set of built-in validators that can be extended by compatible modules (extensions).
Also proved runtime switching between languages, so you can show proper error messages to users.

Uses simple and declarative approach to validate forms:

=head2 Validator

First, you need to create class which will implements
at least one main role: Dancer2::Plugin::FormValidator::Role::Profile.

This role requires profile method which should return a HashRef Data::FormValidator accepts:

    package RegisterForm

    use Moo;
    with 'Dancer2::Plugin::FormValidator::Role::Profile';

    sub profile {
        return {
            username     => [ qw(required alpha_num_ascii length_min:4 length_max:32) ],
            email        => [ qw(required email length_max:127) ],
            password     => [ qw(required length_max:40) ],
            password_cnf => [ qw(required same:password) ],
            confirm      => [ qw(required accepted) ],
        };
    };

=head2 Application

Then you need to set basic configuration:

     set plugins => {
            FormValidator => {
                session => {
                    namespace => '_form_validator' # This is required field
                },
            },
        };

Now you can validate POST parameters in your controller:

    use Dancer2::Plugin::FormValidator;
    use RegisterForm;

    post '/register' => sub {
        if (my $valid_hash_ref = validate profile => RegisterForm->new) {
            if (login($valid_hash_ref)) {
                redirect '/success_page';
            }
        }

        redirect '/register';
    };

    get '/register' => sub {
        template 'app/register' => {
            title  => 'Register page',
        };
    };

=head2 Template

In you template you have access to: $errors - this is HashRef with parameters names as keys
and error messages as ArrayRef values and $old - contains old input values.

Template app/register:

    <div class="w-3/4 max-w-md bg-white shadow-lg py-4 px-6">
        <form method="post" action="/register">
            <div class="py-2">
                <label class="block font-normal text-gray-400" for="name">
                    Name
                </label>
                <input
                        type="text"
                        id="name"
                        name="name"
                        value="<: $old[name] :>"
                        class="border border-2 w-full h-5 px-4 py-5 mt-1 rounded-md
                        hover:outline-none focus:outline-none focus:ring-1 focus:ring-indigo-100"
                >
                <: for $errors[name] -> $error { :>
                    <small class="pl-1 text-red-400"><: $error :></small>
                <: } :>
            </div>
            <div class="py-2">
                <label class="block font-normal text-gray-400" for="email">
                    Name
                </label>
                <input
                        type="text"
                        id="email"
                        name="email"
                        value="<: $old[email] :>"
                        class="border border-2 w-full h-5 px-4 py-5 mt-1 rounded-md
                        hover:outline-none focus:outline-none focus:ring-1 focus:ring-indigo-100"
                >
                <: for $errors[email] -> $error { :>
                    <small class="pl-1 text-red-400"><: $error :></small>
                <: } :>

            <!-- Other fields -->
            ...
            ...
            ...
            <!-- Other fields end -->

            </div>
            <button
                    type="submit"
                    class="mt-4 bg-sky-600 text-white py-2 px-6 rounded-md hover:bg-sky-700"
            >
                Register
            </button>
        </form>
    </div>

=head1 CONFIGURATION

    ...
    plugins:
        FormValidator:
            session:
                namespace: '_form_validator'         # this is required
            messages:
                language: en                         # this is default
                ucfirst: 1                           # this is default
                validators:
                    required:
                        en: %s is needed from config # custom en message
                        de: %s ist erforderlich      # custom de message
                    ...
            extensions:
                dbic:
                    provider: Dancer2::Plugin::FormValidator::Extension::DBIC
                    ...
    ...

=head1 DSL KEYWORDS

=head3 validate

    validate(Hash $params): HashRef|undef

Accept params as hash:

    (
        profile => Object implementing Dancer2::Plugin::FormValidator::Role::Profile # required
        input   => HashRef of values to validate, default is body_parameters->as_hashref_mixed
        lang    => Accepts two-lettered language id, default is 'en'
    )

Profile is required, input and lang is optional.

Returns valid input HashRef if validation succeed, otherwise returns undef.

    if (validate profile => RegisterForm->new) {
        # Success, data is valid.
        my $valid_hash_ref = validated;

        # Do some operations...
    }
    else {
        # Error, data is invalid.
        my $errors = errors;

        # Redirect or show errors...
    }

=head3 validated

    validated(): HashRef|undef

No arguments.
Returns valid input HashRef if validate succeed.
Undef value will be returned after first call within one validation process.

    my $valid_hash_ref = validated;

=head3 errors

    errors(): HashRef

No arguments.
Returns HashRef[ArrayRef] if validation failed.

    my $errors_hash_multi = errors;

=head1 Validators

=head3 accepted

Validates that field B<exists> and one of the listed: (yes on 1).

=head3 alpha

Validate that string only contain of alphabetic utf8 symbols, i.e. /^[[:alpha:]]+$/.

=head3 alpha_ascii

Validate that string only contain of latin alphabetic ascii symbols, i.e. /^[[:alpha:]]+$/a.

=head3 alpha_num

Validate that string only contain of alphabetic utf8 symbols, underscore and numbers 0-9, i.e. /^\w+$/.

=head3 alpha_num_ascii

Validate that string only contain of latin alphabetic ascii symbols, underscore and numbers 0-9, i.e. /^\w+$/a.

=head3 email

=head3 email_dns

=head3 enum

=head3 integer

=head3 length_max:num

Validate that string length <= num.

=head3 length_min:num

Validate that string length >= num.

=head3 max

=head3 min

=head3 numeric

=head3 required

Validate that field exists and not empty string.

=head3 same

=head1 CUSTOM MESSAGES

To define custom error messages for fields/validators your Validator should implement
Role: Dancer2::Plugin::FormValidator::Role::ProfileHasMessages.

    package Validator {
        use Moo;

        with 'Dancer2::Plugin::FormValidator::Role::ProfileHasMessages';

        sub profile {
            return {
                name  => [qw(required)],
                email => [qw(required email)],
            };
        };

        sub messages {
            return {
                name => {
                    required => {
                        en => 'Specify your %s',
                    },
                },
                email => {
                    required => {
                        en => '%s is needed',
                    },
                    email => {
                        en => '%s please use valid email',
                    }
                }
            }
        }
    }

=head1 EXTENSIONS

=head2 Writing custom extensions

You can extend the set of validators by writing extensions:

    package Extension {
        use Moo;

        with 'Dancer2::Plugin::FormValidator::Role::Extension';

        sub validators {
            return {
                is_true  => 'IsTrue',   # Full class name
                email    => 'Email',    # Full class name
                restrict => 'Restrict', # Full class name
            }
        }
    }

Extension should implement Role: Dancer2::Plugin::FormValidator::Role::Extension.

Custom validators:

    package IsTrue {
        use Moo;

        with 'Dancer2::Plugin::FormValidator::Role::Validator';

        sub message {
            return {
                en => '%s is not a true value',
            };
        }

        sub validate {
            my ($self, $field, $input) = @_;

            if (exists $input->{$field}) {
                if ($input->{$field} == 1) {
                    return 1;
                }
                else {
                    return 0;
                }
            }

            return 1;
        }
    }

Validator should implement Role: Dancer2::Plugin::FormValidator::Role::Validator.

Config:

    set plugins => {
        FormValidator => {
            session    => {
                namespace => '_form_validator'
            },
            extensions => {
                extension => {
                    provider => 'Extension',
                }
            }
        },
    };

=head2 Extensions modules

There is a set of ready-made extensions available on cpan:

=over 4

=item *
L<Dancer2::Plugin::FormValidator::Extension::Password|https://metacpan.org/pod/Dancer2::Plugin::FormValidator::Extension::Password>
- for validating passwords.

=item *
L<Dancer2::Plugin::FormValidator::Extension::DBIC|https://metacpan.org/pod/Dancer2::Plugin::FormValidator::Extension::DBIC>
- for checking fields existence in table rows.

=back

=head1 TODO

=over 4

=item *
Document with example all validators.

=item *
Document all config field with explanation.

=item *
Document all Roles and HashRef structures.

=item *
Extensions docs.

=item *
Profile docs.

=item *
Contribution and help details.

=back

=head1 BUGS AND LIMITATIONS

If you find one, please let me know.

=head1 SOURCE CODE REPOSITORY

L<https://github.com/AlexP007/dancer2-plugin-formvalidator|https://github.com/AlexP007/dancer2-plugin-formvalidator>.

=head1 AUTHOR

Alexander Panteleev <alexpan at cpan dot org>.

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2022 by Alexander Panteleev.
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
