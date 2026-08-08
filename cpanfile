requires 'perl', 'v5.40';

requires 'meta';
requires 'Const::Fast';
requires 'Crypt::Argon2';
requires 'Cwd';
requires 'File::HomeDir';
requires 'File::ConfigDir';
requires 'IO::Handle::Common';
requires 'IO::Socket::SSL';
requires 'IPC::Nosh';
requires 'MIME::Types';
requires 'Net::SSLeay';
requires 'Object::Pad';
requires 'Path::Tiny';
requires 'Plack::App::Directory';
requires 'Plack::Builder';
requires 'Plack::MIME';
requires 'Plack::Runner';
requires 'Syntax::Keyword::Dynamically';
requires 'TOML::Tiny';
requires 'Time::Moment';
requires 'Time::Piece';
requires 'Frame';

on 'test' => sub {
    requires 'Test::More', '0.98'
};

on 'develop' => sub {
  requires 'Module::Build::Tiny';
  recommends 'Minilla';
  recommends 'Perl::Critic';
  recommends 'Perl::Tidy';
  recommends 'Carmel'
}

