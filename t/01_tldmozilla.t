use Test::More;
use lib qw( ./lib ../lib );
eval{
  use File::Temp qw/ tempdir /;
  };

if (my $error= $@) { plan skip_all=> 'File::Temp is not installed.' } else {

plan tests=> 4;

$ENV{TLD_MOZILLA_TEMP}= tempdir( CLEANUP => 1 );

require_ok 'Net::Domain::TldMozilla';

can_ok 'Net::Domain::TldMozilla', 'get_tld';

ok my @list= Net::Domain::TldMozilla->get_tld;

ok scalar(@list)> 0;

}
