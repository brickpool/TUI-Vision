package TUI::Common;
# ABSTRACT: Common utilities and constants for the TUI::Vision framework

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000003';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Common::Const;

sub import {
  my $target = caller;
  TUI::Common::Const->import::into( $target, qw( :all ) );
}

sub unimport {
  my $caller = caller;
  TUI::Common::Const->unimport::out_of( $caller );
}

1

__END__

=pod

=head1 NAME

TUI::Common - common constants for the TUI::Vision framework

=head1 SYNOPSIS

  use TUI::Common;

  my $find_limit = maxFindStrLen;

=head1 DESCRIPTION

C<TUI::Common> is an umbrella for L<TUI::Common::Const>. Using this module
imports all constants defined there into the calling package. C<no TUI::Common>
removes those imports from the caller.

=head1 SEE ALSO

L<TUI::Common::Const>

=cut
