#!/usr/bin/env perl

use Object::Pad ':experimental(:all)';

package srvdir;

class srvdir : strict(params);

use utf8;
use v5.40;

use lib 'lib';

use Path::Tiny;
use Getopt::Long qw'GetOptionsFromArray :config bundling auto_abbrev';
use Plack::Runner;
use Cwd 'abs_path';
use IPC::Nosh::Common;
use WWW::srvdir;

field $argv : param;
field $app;
field $srvpath :param(srvpath) = path(abs_path);
field $config_file;

field $cliopts : param(dest) : reader = {
    ssl => {
        'ssl'        => 1,
        'ssl-server' => 1
    },

};

ADJUSTPARAMS($params) {
    GetOptionsFromArray(
        $argv, $cliopts,

        #'ssl|tls|x509',
        'username=s',
        'password=s',
        'verbose',
        'debug', 'help',
        'version',
        'config-file|config-path=s',
        '<>' => sub ($barearg) {
            state $_set //= 0;
            die "\$ARGV[0] has already been set to '$srvpath'" if $_set != 0;
            $_set = 1 && $srvpath = path($barearg);

            dmsg(
                {
                    self    => $self,
                    cliopts => $cliopts,
                    _set    => $_set,
                    srvpath => $srvpath
                }
            );
        }
    );

    $app = WWW::srvdir->new( root => $srvpath, mount => '/' );
}

method to_app {
    $app->to_app, $self;
}

package main;

class main;

use utf8;
use v5.40;

use IPC::Nosh::Common;

our ( $app, $srvdir ) = srvdir->new( argv => \@ARGV )->to_app;
our $cliopts = $srvdir->cliopts;

unless (caller) {
    require Plack::Runner;
    my $runner = Plack::Runner->new;
    $runner->parse_options( $cliopts->{ssl}->%*, @ARGV );

    if ( $$cliopts{pass} isa 'HASH' && $cliopts->{pass}{crypt} ) {
        ...;
    }

    $runner->run($app);

    dmsg( { runner => $runner, app => $app } );

    warn "$! ($?)" if $? != 0;
    exit $?;
}

return $app;
