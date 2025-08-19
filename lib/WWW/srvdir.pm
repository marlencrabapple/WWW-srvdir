use Object::Pad ':experimental(:all)';

package WWW::srvdir;
class WWW::srvdir :does(WWW::srvdir::config);

use utf8;
use v5.40;

our $VERSION = "0.01";

use meta;
use Path::Tiny;
use MIME::Types 'by_suffix';
use Data::Dumper;
use Const::Fast;
use Plack::App::Directory;
use Plack::MIME;
use MIME::Types;
use Const::Fast;
use Const::Fast::Exporter;
use Syntax::Keyword::Dynamically;
use Time::Moment;
use Time::Piece;

use Exporter qw(import);

BEGIN {
    our @EXPORT = qw(dmsg);
}

our $DEBUG = $ENV{DEBUG} // 0;

eval { use Devel::StackTrace::WithLexicals } if $DEBUG;

use subs 'dmsg';

Plack::MIME->set_fallback(sub { (by_suffix $_[0])[0] });

field $root = '.';
field $mount = '/';
field $app { Plack::App::Directory->new({ root => "/path/to/htdocs" })->to_app }
field $builder { Plack::Builder->new }

sub dmsg (@msgs) {
    $DEBUG || return '';

    my @caller = caller 0;

    my $out = "*** " . localtime->datetime . " - DEBUG MESSAGE ***\n\n";

    {
        dynamically $Data::Dumper::Pad    = "  ";
        dynamically $Data::Dumper::Indent = 1;

        $out .=
            scalar @msgs > 1 ? Dumper(@msgs)
          : ref $msgs[0]     ? Dumper(@msgs)
          :                    eval { my $s = $msgs[0] // 'undef'; "  $s\n" };

        $out .= "\n"
    }

    $out .=
      $ENV{DEBUG} && $ENV{DEBUG} == 2
      ? join "\n", map { ( my $line = $_ ) =~ s/^\t/  /; "  $line" } split /\R/,
      Devel::StackTrace::WithLexicals->new(
        indent      => 1,
        skip_frames => 1
      )->as_string
      : "at $caller[1]:$caller[2]";

    say STDERR "$out\n";
    $out;
}

method to_psgi {
  $builder->to_app(@_)
}

method to_app {
  $self->to_psgi(@_)
}

ADJUSTPARAMS ($params) {
  $builder->mount($mount => $root);
  dmsg({self => $self})
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

