use Object::Pad ':experimental(:all)';

package WWW::srvdir;

class WWW::srvdir : does(WWW::srvdir::Config) : does(WWW::srvdir::User);

use utf8;
use v5.40;

our $VERSION = "0.01";

use Path::Tiny;
use MIME::Types 'by_suffix';
use Plack::Builder;
use Plack::App::Directory;
use Plack::MIME;
use List::Util qw'first all';
use IO::Handle::Common;

# use WWW::srvdir::User;
# use WWW::srvdir::Util;

Plack::MIME->set_fallback( sub { ( by_suffix $_[0] )[0] } );

field $debug  : accessor //= $ENV{DEBUG};
field $root   : param    //= '.';
field $mount  : param    //= '/';
field $cliopt : param = undef;

field $app;
field $builder { Plack::Builder->new }

ADJUST {
    if (   scalar $self->userdb->@* == 0
        && scalar( grep { $_ } @ENV{qw'SRVDIR_USER SRVDIR_PASS'} ) == 2 )
    {
        $self->add_user( $ENV{SRVDIR_USER}, $ENV{SRVDIR_PASS} );
    }

    foreach my $user ( $self->config->{userdb}->@* ) {
        $self->add_user( delete $$user{user}, %$user );
    }
}

method to_psgi {
    $builder->to_app(@_);
}

method to_app {
    $self->to_psgi(@_);
}

method auth_basic ( $user, $pass, $env ) {
    first { $$_->user eq $user && argon2_verify( $pass, $$_->crypt ) }
      $self->userdb->@*;
}

ADJUST {
    $app = Plack::App::Directory->new( root => $root );

    if ( $ENV{DEBUG} || $self->debug ) {
        $builder->add_middleware('Debug');
        $builder->add_middleware('StackTrace');
        $builder->add_middleware(
            'Auth::Basic',
            authen_cb => sub ( $user, $pass, $env ) {
                $self->auth_basic( $user, $pass, $env );
            }
        ) if scalar $self->userdb->@*;
    }

    $builder->mount( $mount => $app->to_app );

}

__END__

=encoding utf-8

=head1 NAME

WWW::srvdir - It's new $module

=head1 SYNOPSIS

    use WWW::srvdir;

=head1 DESCRIPTION

WWW::srvdir is ...

=head1 LICENSE

Copyright (C) Ian Bradley.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ian Bradley E<lt>crabapp@hikki.techE<gt>

=cut

