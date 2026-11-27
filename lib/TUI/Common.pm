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
use TUI::Common::Text;

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

TUI::Common - common constants and text resources

=head1 SYNOPSIS

  use TUI::Common;

  my $find_limit = maxFindStrLen;

=head1 DESCRIPTION

C<TUI::Common> loads L<TUI::Common::Const> and L<TUI::Common::Text>.
Using this module imports all constants from L<TUI::Common::Const> into the
calling package. The text globals are initialized in their original packages
and are not imported. C<no TUI::Common> does not remove the imported
constants.

=head1 AUTHORS

=over

=item * Borland International (original Turbo Vision design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 CONTRIBUTORS

Contributors are documented in the POD of the respective framework modules.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 1990-1994, 1997 by Borland International

Copyright (c) 2026 the L</AUTHORS> as listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut
