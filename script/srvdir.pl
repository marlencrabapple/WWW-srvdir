#!/usr/bin/env perl

use Object::Pad ':experimental(:all)';

package srvdir;

class srvdir;    # : strict(params);

use utf8;
use v5.40;

# use lib 'lib';

use Path::Tiny;
use Getopt::Long
  qw(GetOptionsFromArray :config no_ignore_case auto_abbrev passthrough bundling long_prefix_pattern=--?);
use Plack::Runner;
use IO::Handle::Common;
use WWW::srvdir;

field $argv : param;
field $app;
field $srvpath : param(srvpath) = undef;

field $cliopt : param(dest) : reader = {
    ssl => {
        'ssl'        => 1,
        'ssl-server' => 1
    },
};

ADJUSTPARAMS($params) {
    GetOptionsFromArray(
        $argv, $cliopt,

        'ssl|tls|x509:s',    # = server, client, mutual (default: server)
        'certfile|certificate:s',
        'validpath|intermediates|trustchain:s@'
        , # intermediate(s) as separate files (we may produce more specialized bundles similar to cfssl)
        'certbundle:s'
        ,    # leaf cert with intermediates/trust chain in a single file

        # 'intermediates|chain'
        'keyfile:s',

        # Auth Basic
        'user|username:s',
        'pwhash|password-hash|crypt:s',           # argon2 hash
        'login|login-credentials|credentials:s',    # user:pwhash

        'verbose+',
        'debug', 'help',
        'version',

        'config|config-file|config-path:s@',

        '<>' => sub ($barearg) {
            state $_set //= 0;

            fatal
"Warning: Directory has already been set via positional paramenter to '$srvpath'."
              if $_set == 1;

            say STDERR "Root directory changed from '$srvpath' -> '$barearg'"
              if $srvpath;

            $srvpath = $barearg;
            $_set++;
        }
    );

    $srvpath //= path("./")->absolute;

    $app = WWW::srvdir->new(
        $cliopt->%{qw'user pwhash debug verbose config'},
        cliopt => $cliopt,
        root   => $srvpath,
        mount  => '/'
    );
}

method to_app {
    $app->to_app, $self;
}

package srvdir::cli;

class srvdir::cli;

use utf8;
use v5.40;

use IO::Handle::Common;

our ( $app, $srvdir ) = srvdir->new( argv => \@ARGV )->to_app;
our $cliopt = $srvdir->cliopt;

unless (caller) {
    require Plack::Runner;
    my $runner = Plack::Runner->new;
    $runner->parse_options( $cliopt->{ssl}->%*, @ARGV );

    dmsg $app, $srvdir, $cliopt, $runner;

    $runner->run($app);

    error "$! ($?)" if $? > 0;
    exit $?;
}

return $app;
