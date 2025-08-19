requires 'perl', 'v5.40';

requires 'meta';
requires 'Path::Tiny';
requires 'MIME::Types';
requires 'Data::Dumper';
requires 'Const::Fast';
requires 'Plack::App::Directory';
requires 'Plack::Runner';
requires 'Plack::Builder';
requires 'Cwd';
requires 'Plack::MIME';
requires 'MIME::Types';
requires 'Const::Fast';
requires 'Const::Fast::Exporter';
requires 'Syntax::Keyword::Dynamically';
requires 'Time::Moment';
requires 'Time::Piece';
requires 'Net::SSLeay';
requires 'IO::Socket::SSL';
requires 'File::XDG';
requires 'Net::Async::HTTP::Server';
requires 'TOML::Tiny';

on 'test' => sub {;
    requires 'Test::More', '0.98';
};

