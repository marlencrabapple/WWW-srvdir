#!/usr/bin/env plackup
#
use Object::Pad ':experimental(:all)';

package perldoc_browser;

class perldoc_browser;

use v5.40;

use Plack::Builder;
use Plack::Middleware::Rewrite;
use Plack::Middleware::ReverseProxy;
use Plack::Middleware::StackTrace;
use Plack::Middleware::Debug;
use Path::Try;
use List::Util qw'uniqstr';
use Getopt::Long;
use IO::Handle::Common;

# qw(GetOptionsFromArray :config no_ignore_case auto_abbrev passthrough bundling long_prefix_pattern=--?);

#use subs 'refstr';

field $builder : reader = Plack::Builder->new;
field $pathmap : reader = [];
field $execdir : reader = [];

ADJUST : params (:$pathmap //= undef) {
    if ( __CLASS__->refstr($pathmap) eq 'HASH' ) {

        if (
            ( scalar uniqstr grep { $_ =~ /root|mount/ } keys %$pathmap ) eq 2 )
        {
            $self->adjust( $pathmap, [ $self->pathmap->@*, $pathmap ] );
        }
        elsif ( !reftype($pathmap) ) {
            if ( my ( $root, $mount ) = /^([^:]+):([.+])$/ ) {
                $self->adjust( $pathmap,
                    [ $self->pathmap->@*, { root => $root, mount => $mount } ]
                );
            }
        }
    }
};

method refstr : common ($ref) {
    return reftype($ref) // '';
}

method adjust ( $field, $val ) {
    my $varname = var_name( 0, $field );

    if ( !reftype($field) ) {

        # do nothing for now
        # eval "$varname = \$val" if $varname;
    }
    elsif ( reftype($field) eq 'ARRAY' ) {
        my $curr;
        eval "\$curr = $varname";
        $val = [ @$curr, $val ];
    }
    else {
        ...;
    }

    eval "$varname = \$val" if $varname;

    $self;
}

method mount_middlware (@arg) {
    $builder->add_middleware_if(
        sub ($env) { !$env->{REMOTE_ADDR} },
        "Plack::Middleware::ReverseProxy"
    );

    if ( $ENV{PLACK_ENV} && ( $ENV{PLACK_ENV} eq 'development' ) ) {
        $builder->add_middleware('Debug');
        $builder->add_middleware('StackTrace');
    }
}

method mount_pathmap {
    foreach my ( $root, $mount ) (@$pathmap) {
        $builder->mount( $mount => Plack::Util::load_psgi($root) );
    }
}

method to_psgi {
    $self->mount_pathmap;
    dmsg $self;
    $self->mount_middlware;
    dmsg $self;
    $builder->to_app;
}

*to_app = \&to_psgi;

package perldoc_browser::CLI;

use utf8;
use v5.40;

use Data::Printer;
use List::Util qw'any';
use Getopt::Long
  qw(GetOptionsFromArray :config no_ignore_case auto_abbrev passthrough bundling long_prefix_pattern=--?);
use IO::Handle::Common;
use Const::Fast;

sub cli ( $argv = \@ARGV ) {
    our %cliopt;

    my $pathmap_multival_err = sub {
        state $count //= 0;
        my $errstr = "Local root and URI mount path have already been set: ";

        p $cliopt{root}, $cliopt{mount};

        $errstr .=
"Use only the 'root:mount' format as a value for --pathmap () or as positional arguments to set multiple custom mappings.";

        $count++;
    };

    const my %baremap => ( 0 => 'root', 1 => 'mount' );

    GetOptionsFromArray(
        $argv,
        \%cliopt,
        'pathmap:s',
        'srvroot:s',
        'mount:s',
        '<>' => sub ($bare) {
            state $count //= 0;

            if ( my ( $root, $mount ) = /^([^:]+):([.+])$/ ) {
                if ( $count || any { $_ } @cliopt{qw'root mount'} ) {
                    pathmap_multival_err();
                }

                $cliopt{pathmap} = { root => $root, mount => $mount };
            }
            else {
                if ( $count > 1 ) {
                    pathmap_multival_err();
                }
                $cliopt{ $baremap{$count} } = $bare;
            }

        }
    );

    shift @$argv if ( refstr( @$argv[0] ) eq 'ARRAY' && @$argv[0] eq '--' );

    p \%cliopt, $argv;

    return %cliopt;
}

my $app = perldoc_browser->new( cli( \@ARGV ) );
p $app, @ARGV;
my $psgi = $app->to_psgi;
p $psgi;

unless (caller) {
    require Plack::Runner;

    my $runner = Plack::Runner->new;
    $runner->parse_options(@ARGV);

    $runner->run($psgi);

    error "$! ($?)" if $? > 0;
    exit $?;
}

return $psgi

  #our %cliopt;

  # sub pathmap_multival_err () {
  #     state $count //= 0;
  #     my $errstr = "Local root and URI mount path have already been set: ";

  #     p $cliopt{root}, $cliopt{mount};

#     $errstr .=
# "Use only the 'root:mount' format as a value for --pathmap () or as positional arguments to set multiple custom mappings.";

  #     $count++;
  # }

  # GetOptions(
  #     \%cliopt,
  #     'pathmap:s',
  #     'srvroot:s',
  #     'mount:s',
  #     '<>' => sub ($bare) {
  #         state $count //= 0;

  #         if ( my ( $root, $mount ) = /^([^:]+):([.+])$/ ) {
  #             if ( $count || any { $_ } @cliopt{qw'root mount'} ) {
  #                 pathmap_multival_err();
  #             }
  #         }
  #         else {
  #             if ( $count > 1 ) {
  #                 pathmap_multival_err();
  #             }
  #         }
  #     }
  # );

  # our $app = perldoc_browser->new( \%cliopt );
  # dmsg \%cliopt, \@ARGV, $app;
  # $app->to_psgi;

