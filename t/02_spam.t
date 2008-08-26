use Test::More;
use lib qw( ./lib ../lib );
eval{
  use File::Temp qw/ tempdir /;
  };

if (my $error= $@) { plan skip_all=> 'File::Temp is not installed.' } else {

unless ($ENV{SPAMER_ARGS}) { plan skip_all=> qq{'SPAMER_ARGS' environment is empty. } } else{

$ENV{TLD_MOZILLA_TEMP}= tempdir( CLEANUP => 1 );

require Net::SPAMerLookup;

plan tests=> 6;

ok my $spam= Net::SPAMerLookup->new, q{Constructor.};

can_ok $spam, 'import';

can_ok $spam, 'check_rbl';
  ok $spam->check_rbl($ENV{SPAMER_ARGS});

can_ok $spam, 'is_spamer';
  ok $spam->is_spamer($ENV{SPAMER_ARGS});

} }
