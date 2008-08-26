package Net::SPAMerLookup;
#
# Masatoshi Mizuno E<lt>lusheE(<64>)cpan.orgE<gt>
#
# $Id: SPAMerLookup.pm 366 2008-08-26 05:15:13Z lushe $
#
use strict;
use warnings;
use Net::DNS;
use Net::Domain::TldMozilla;

our $VERSION = '0.04';

my @RBL= qw/
 all.rbl.jp
 url.rbl.jp
 dyndns.rbl.jp
 notop.rbl.jp
 bl.spamcop.net
 list.dsbl.org
 sbl-xbl.spamhaus.org
 bsb.empty.us
 bsb.spamlookup.net
 niku.2ch.net
 /;

my $TLDregex= do {
	my $tld= Net::Domain::TldMozilla->get_tld;
	join '|', map{quotemeta($_)}@$tld;
  };

sub import {
	my $class= shift;
	@RBL= @_ if @_;
	$class;
}
sub new {
	bless []; ## no critic.
}
sub check_rbl {
	my $self= shift;
	my $args= shift || die q{I want 'host name' or 'IP address' or 'URL'.};
	if ($args=~m{^https?\://([^/\:]+)}) {
		$args= $1;
		$args=~s/^[^\@]+\@//;
	} elsif ($args=~m{\@([^\@]+)$}) {
		$args= $1;
	}
	my $dns= Net::DNS::Resolver->new;
	my $check= $args=~m{^\d{1.3}\.\d{1.3}\.\d{1.3}\.\d{1.3}$} ? sub {
		my $q= $dns->search("$args.$_[0]", 'PTR') || return 0;
		{
		  address=> $args,
		  result => [ map{$_->ptrdname}grep($_->type eq 'PTR', $q->answer) ],
		  };
	  }: do {
		my($domain)= $args=~m{([^\.]+\.(?:$TLDregex))$};
		sub {
			my $q= $dns->search("$args.$_[0]", 'A') || do {
				return 0 if (! $domain or $domain eq $args);
				$args= $domain;
				$dns->search("$args.$_[0]", 'A') || return 0;
			  };
			{
			  name  => $args,
			  result=> [ map{$_->address}grep($_->type eq 'A', $q->answer) ],
			  };
		  };
	  };
	for (@RBL) {
		my $hit= $check->($_) || next;
		return { %$hit, RBL=> $_ };
	}
	0;
}
sub is_spamer {
	my $self= shift;
	for (@_) { if (my $target= $self->check_rbl($_)) { return $target } }
	0;
}

1;

__END__

=head1 NAME

Net::SPAMerLookup - Perl module to judge SPAMer.

=head1 SYNOPSIS

  use Net::SPAMerLookup qw/
    all.rbl.jp
    url.rbl.jp
    dyndns.rbl.jp
    notop.rbl.jp
    bl.spamcop.net
    list.dsbl.org
    sbl-xbl.spamhaus.org
    bsb.empty.us
    bsb.spamlookup.net
    niku.2ch.net
    /;
  
  my $spam= Net::SPAMerLookup->new;
  if ($spam->check_rbl($TARGET)) {
  	print "It is SPAMer.";
  } else {
  	print "There is no problem.";
  }
  
  # Whether SPAMer is contained in two or more objects is judged.
  if (my $spamer= $spam->is_spamer(@TARGET)) {
  	print "It is SPAMer.";
  } else {
  	print "There is no problem.";
  }

=head1 DESCRIPTION

SPAMer is judged by using RBL.

=head1 SETTING RBL USED

When passing it to the start option.

  use Net::SPAMerLookup qw/ all.rbl.jp .....  /;

When doing by the import method.

  require Net::SPAMerLookup;
  Net::SPAMerLookup->import(qw/ all.rbl.jp ..... /);

=head1 METHODS

=head2 new

Constructor.

  my $spam= Net::SPAMerLookup;

=head2 check_rbl ([ FQDN or IP_ADDR or URL ])

'Host domain name', 'IP address', 'Mail address', and 'URL' can be passed to the argument.

HASH including information is returned when closing in passed value RBL.

0 is returned when not closing.

Following information enters for HASH that was able to be received.

=over 4

=item * RBL

RBL that returns the result enters.

=item * name or address

The value enters 'Address' at 'Name' and "IP address" when the object is "Host domain name" form.

=item * result

Information returned from RBL enters by the ARRAY reference.

=back 

  if (my $result= $spam->check_rbl('samp-host-desuka.com')) {
    print <<END_INFO;
    It is SPAMer.
  
  RBL-Server: $result->{RBL}
  
  @{[ $result->{name} ? qq{Name: $result->{name}}: qq{Address: $result->{address}} ]}
  
  @{[ join "\n", @{$result->{result}} ]}
  
  END_INFO
  } else {
    print "There is no problem.";
    ......
    ...

=head2 is_spamer ([TARGET_LIST])

'check_rbl' is continuously done to two or more objects.

And, HASH that 'check_rbl' returned is returned as it is if included.

  if (my $result= $spam->is_spamer(@TAGER_LIST)) {
    .........
    ....

=head1 SEE ALSO

L<Net::DNS>;

=head1 AUTHOR

Masatoshi Mizuno E<lt>lushe(E<64>)cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Bee Flag, Corp. E<lt>http://egg.bomcity.com/E<gt>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

