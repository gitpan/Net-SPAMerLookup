use inc::Module::Install;

name          'Net-SPAMerLookup';
all_from      'lib/Net/SPAMerLookup.pm';
version_from  'lib/Net/SPAMerLookup.pm';
abstract_from 'lib/Net/SPAMerLookup.pm';
author        'Masatoshi Mizuno E<lt>lushe(E<64>)cpan.orgE<gt>';
license       'perl';

requires 'File::Slurp' => '9999.13';
requires 'HTTP::Lite'  => '2.1.6';
requires 'Net::DNS'    => '0.63';

build_requires 'Test::More';
build_requires 'Test::Pod';
build_requires 'Test::Perl::Critic';
build_requires 'Test::Pod::Coverage';

use_test_base;
auto_include;
WriteAll;
