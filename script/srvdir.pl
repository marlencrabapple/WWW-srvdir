#!/usr/bin/env perl

use utf8;
use v5.40;

use Object::Pad ':experimental(:all)';

use Plack::Runner;
use Plack::Builder;
use Cwd;
use Plack::App::Directory;

use lib 'lib';

use WWW::srvdir;

my $app = WWW::srvdir->new->to_app;

unless (caller) {
    require Plack::Runner;
    my $runner = Plack::Runner->new;
    $runner->parse_options(@ARGV);
    $runner->run($app);
    exit 0;
}

return $app;