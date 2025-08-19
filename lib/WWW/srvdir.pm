use Object::Pad ':experimental(:all)';

package WWW::srvdir;

class WWW::srvdir : does(WWW::srvdir::Base) : does(WWW::srvdir::config);

use utf8;
use v5.40;

our $VERSION = "0.01";

use meta;
use Path::Tiny;
use MIME::Types 'by_suffix';
use Plack::Builder;
use Plack::App::Directory;
use Plack::MIME;
use MIME::Types;
use Const::Fast;
use Const::Fast::Exporter;
use Syntax::Keyword::Dynamically;

use WWW::srvdir::Base;

Plack::MIME->set_fallback( sub { ( by_suffix $_[0] )[0] } );

field $root  : param //= '.';
field $mount : param //= '/';
field $app;
field $builder { Plack::Builder->new }

# method call ($env) {
#     $app->call($env);
# }

method to_psgi {
    $builder->to_app(@_);
}

method to_app {
    $self->to_psgi(@_);
}

ADJUSTPARAMS($params) {
    $app = Plack::App::Directory->new( root => $root );
    
    if ($WWW::srvdir::DEBUG || $self->debug) {
      $builder->add_middleware('Debug');
      $builder->add_middleware('StackTrace');
    }
   
    $builder->mount( $mount => $app->to_app );
    dmsg(
        { self => $self, builder => $builder, app => $app, params => $params } )
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

