use v5.40;
use subs qw'requires recommends on feature';

requires 'perl', 'v5.40';

requires 'meta';
requires 'Const::Fast';
requires 'Crypt::Argon2';
requires 'Cwd';
requires 'File::ConfigDir';
requires 'IO::Handle::Common';
requires 'IO::Socket::SSL';
requires 'IPC::Nosh', '0.01.3';
requires 'MIME::Types';
requires 'Net::SSLeay';
requires 'Object::Pad';
requires 'Path::Try';
requires 'Plack::App::Directory';
requires 'Plack::Builder';
requires 'Plack::MIME';
requires 'Plack::Runner';

# requires 'Plack::Middleware::ReverseProxy';
# requires 'Plack::Middleware::Rewrite';
# requires 'Plack::Middleware::Auth::Basic';
# requires 'Plack::Middleware::Static';
requires 'Syntax::Keyword::Dynamically';
requires 'TOML::Tiny';
requires 'Time::Moment';
requires 'Time::Piece';
requires 'Frame';
requires 'Server::Starter';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

on 'develop' => sub {
    requires 'Module::Build::Tiny';
    requires 'Plack::Middleware::Debug';

    # requires 'Devel::Trace';
    requires 'Plack::Middleware::StackTrace';
    recommends 'Minilla';
    recommends 'Perl::Critic';
    recommends 'Perl::Tidy';
    recommends 'Carton';
}

