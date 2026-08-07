#!/usr/bin/env perl

package srvdir::CLI;

use utf8;
use v5.40;

# use lib 'lib';

use Path::Tiny;
use Getopt::Long
  qw(GetOptionsFromArray :config no_ignore_case auto_abbrev bundling long_prefix_pattern=--?);

use Const::Fast;
use IO::Handle::Common;
use WWW::srvdir;

sub run ( $argv = \@ARGV ) {
    my %cliopt = ();

    const my %pos_dest => ( 0 => 'root', 1 => 'mount' );

    GetOptionsFromArray(
        $argv, \%cliopt,

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
        'pwhash|password-hash|crypt:s',             # argon2 hash
        'login|login-credentials|credentials:s',    # user:pwhash

        'verbose+',
        'debug', 'help',
        'version',

        'config|config-file|config-path:s@',

        '<>' => sub ($barearg) {
            state $pos //= 0;
            $cliopt{ $pos_dest{$pos} } = $barearg;
        }
    );

    WWW::srvdir->new(
        map { $_ =~ s/-/_/; ( $_ => $cliopt{$_} ) }
          keys %cliopt
    );

}

package srvdir::Runner;

use utf8;
use v5.40;

use IO::Handle::Common;

# our ( $psgi, $srvdir ) = srvdir::CLI->run( \@ARGV )->to_app;
# our $cliopt = $srvdir->cliopt;

my $srvdir = srvdir::CLI::run( \@ARGV );
my $psgi   = $srvdir->to_psgi;

unless (caller) {
    require Plack::Runner;
    my $runner = Plack::Runner->new;
    $runner->parse_options(@ARGV);

    dmsg $psgi, $srvdir, $runner;

    $runner->run($psgi);

    error "$! ($?)" if $? > 0;
    exit $?;
}

return $psgi
