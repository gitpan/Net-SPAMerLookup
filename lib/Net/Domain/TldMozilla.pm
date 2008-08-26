package Net::Domain::TldMozilla;
#
# Masatoshi Mizuno E<lt>lusheE(<64>)cpan.orgE<gt>
#
# $Id: TldMozilla.pm 366 2008-08-26 05:15:13Z lushe $
#
use strict;
use warnings;
use LWP::Simple;
use File::Slurp;
use Jcode;

our $VERSION = '0.01';

sub get_tld {
#
# ------------------------------------------------------------------------------------------
my $url = $ENV{TLD_MOZILLA_URL}
   || 'http://mxr.mozilla.org/firefox/source/netwerk/dns/src/effective_tld_names.dat?raw=1';
my $temp= ($ENV{TLD_MOZILLA_TEMP} || '/tmp'). '/mozilla_tld.cache';
# ------------------------------------------------------------------------------------------
#
	my $TLD= do {
		my $read= sub { my $plain= read_file($temp); [ split /\s*\n\s*/, $plain ] };
		(! -e $temp or (-M _)> 3) ? do {
			if (my $source= LWP::Simple::get($url)) {
				my @tld;
				for (split /\n/, $source) {
					next if (! $_ or /^\s*(?:\/|\#)/);
					my $icode= Jcode::getcode(\$_) || next;
					next if $icode ne 'ascii';
					s/^\s*\*\.?//;
					s/^\s*\!\s*\.?//;
					push @tld, $_;
				}
				write_file($temp, ( join("\n", @tld) || '' ));
				warn __PACKAGE__. " - data save. [$temp]";
				\@tld;
			} else {
				-e $temp ? do {
					warn __PACKAGE__. " - Unable to get document: $!";
					$read->();
				  }: do {
					die __PACKAGE__. " - Unable to get document: $!";
				  };
			}
		  }: do {
			$read->();
		  };
	  };
	wantarray ? @$TLD: $TLD;
}

1;

__END__

=head1 NAME

Net::Domain::TldMozilla - TLD of the Mozilla source is returned.

=head1 SYNOPSIS

  use Net::Domain::TldMozilla;
  
  my @Tld= Net::Domain::TldMozilla->get;

=head1 DESCRIPTION

TLD is acquired and returned from the source open to the public on the Mozilla site.

=head1 METHODS

=head2 get_tld

The list of TLD is returned.

  my $TLD= Net::Domain::TldMozilla->get;

=head1 ENVIRONMENT VARIABLE

The following environment variables are treated.

=over 4

=item * TLD_MOZILLA_URL

So that URL of the Mozilla site may change.

=item * TLD_MOZILLA_TEMP

Passing preservation of cache file ahead.

Default is '/tmp'.

=back

=head1 SEE ALSO

L<LWP::Simple>,
L<File::Slurp>,
L<Jcode>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lushe(E<64>)cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Bee Flag, Corp. E<lt>http://egg.bomcity.com/E<gt>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

