#!/usr/bin/env perl

use Object::Pad ':experimental(:all)';

package srvdir;

class srvdir;    # : strict(params);

use utf8;
use v5.40;

use lib 'lib';

use Path::Tiny;
use Getopt::Long qw'GetOptionsFromArray :config bundling auto_abbrev';
use Plack::Runner;
use IO::Handle::Common;
use WWW::srvdir;

field $argv : param;
field $app;
field $srvpath : param(srvpath) = path("./")->absolute;

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
        'keyfile=s',

        # Auth Basic
        'user|username:s',
        'pwhash|password-hash|crypt:s', # argon2 hash
        'login|login-credentials|credentials', # user:pwhash

        'verbose+',
        'debug', 'help',
        'version',

        'config|config-file|config-path=s@',

        '<>' => sub ($barearg) {
            state $_set //= 0;

            #die "\$ARGV[0] has already been set to '$srvpath'" if $_set != 0;
            fatal "Directory has already been set to '$srvpath'."
              if $_set = 1 && $srvpath eq path($barearg);

            say STDERR "Root directory changed from $srvpath -> $barearg";
            $srvpath = $barearg;
        }
    );

    $app = WWW::srvdir->new(
        $cliopt->%{qw'username pwhash debug verbose config'},
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
