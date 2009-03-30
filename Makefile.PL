use inc::Module::Install;

name 'Audio-XMMSClient-AnyEvent';
all_from 'lib/Audio/XMMSClient/AnyEvent.pm';

build_requires 'Catalyst::Runtime';
build_requires 'Test::WWW::Mechanize::Catalyst';
build_requires 'Test::More';
build_requires 'ok';

WriteAll();
