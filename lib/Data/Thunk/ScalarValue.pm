#!/usr/bin/perl

package Data::Thunk::ScalarValue;

use strict;
use warnings;

use Carp;
use Check::ISA;

use namespace::clean;

use UNIVERSAL::ref;

our $vivify_scalar;

BEGIN {
	$vivify_scalar = sub {
		my $self = $_[0];

		# must rebless to something unoverloaded in order to get at the value
		bless $self, "Data::Thunk::NoOverload";
		my $val = $$self;
		bless $self, __PACKAGE__;

		# try to replace the container with the value wherever we found it
		local $@;
		eval { $_[0] = $val }; # might be readonly;

		$val;
	};
}

use overload (
	fallback => 1, map {
		$_ => $vivify_scalar,
	} qw( bool "" 0+ ${} @{} %{} &{} *{} )
);

sub ref {
	CORE::ref($_[0]->$vivify_scalar());
}
sub does {
	$_[0]->$vivify_scalar($_[1]);
}

sub AUTOLOAD {
	my ( $method ) = ( our $AUTOLOAD =~ /([^:]+)$/ );
	$_[0]->$vivify_scalar();
	unshift @_, $method;
	goto $Data::Thunk::Code::call_method;
}

sub DESTROY { }

1;
