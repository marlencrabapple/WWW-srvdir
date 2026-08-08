#!/usr/bin/env perl

package srvdir::CLI;

use utf8;
use v5.40;

use lib 'lib';

use Path::Tiny;
use Getopt::Long
  qw(GetOptionsFromArray :config no_ignore_case bundling passthrough autoabbrev);
use Const::Fast;
use IO::Handle::Common;
use WWW::srvdir;

sub configure ( $argv //= \@ARGV ) {
    my %cliopt = ();

    const my %pos_dest => ( 0 => 'root', 1 => 'mount' );

    GetOptionsFromArray(
        $argv, \%cliopt,

        # 'port:i',
        'ssl|tls|x509:s',    # = server, client, mutual (default: server)
        'certfile|certificate|ssl-cert-file|ssl-certfile:s',
        'validpath|intermediates|trustchain:s@'
        , # intermediate(s) as separate files (we may produce more specialized bundles similar to cfssl)
        'certbundle:s'
        ,    # leaf cert with intermediates/trust chain in a single file

        # 'intermediates|chain:s'
        'keyfile|key|ssl-key-file|ssl-keyfile:s',

        # Auth Basic
        'user|username:s',
        'pwhash|password-hash|crypt:s',             # argon2 hash
        'login|login-credentials|credentials:s',    # user:pwhash

        'verbose+',
        'debug', 'help',
        'version',

        'config|config-file|config-path:s@',

        '<>' => sub ($barearg) {
            state $pos //= 0;

            error "Positional arguments for 'root' and and 'mount' have already"
              . " been set.\n Ignoring '$barearg'."
              if $pos > 1;

            $cliopt{ $pos_dest{$pos} } = $barearg;
            $pos++;
        }
    );

    shift @$argv if ( @$argv[0] eq '--' );

    WWW::srvdir->new(
        map { $_ =~ s/-/_/; ( $_ => $cliopt{$_} ) }
          keys %cliopt
    );

}

package srvdir::Runner;

use utf8;
use v5.40;

use IO::Handle::Common;

my $srvdir = srvdir::CLI::configure( \@ARGV );
my $psgi   = $srvdir->to_psgi;

unless (caller) {
    require Plack::Runner;

    my $runner = Plack::Runner->new;
    $runner->parse_options(@ARGV);

    $runner->run($psgi);

    error "$! ($?)" if $? > 0;
    exit $?;
}

return $psgi
