package TUI::Objects;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Objects::Const;
use TUI::Objects::Object;
use TUI::Objects::Point;
use TUI::Objects::Rect;
use TUI::Objects::NSCollection;
use TUI::Objects::NSSortedCollection;
use TUI::Objects::Collection;
use TUI::Objects::SortedCollection;
use TUI::Objects::StringCollection;

sub import {
  my $target = caller;
  TUI::Objects::Const->import::into( $target, qw( :all ) );
  TUI::Objects::Object->import::into( $target );
  TUI::Objects::Point->import::into( $target );
  TUI::Objects::Rect->import::into( $target );
  TUI::Objects::NSCollection->import::into( $target );
  TUI::Objects::NSSortedCollection->import::into( $target );
  TUI::Objects::Collection->import::into( $target );
  TUI::Objects::SortedCollection->import::into( $target );
  TUI::Objects::StringCollection->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::Objects::Const->unimport::out_of( $caller );
  TUI::Objects::Object->unimport::out_of( $caller );
  TUI::Objects::Point->unimport::out_of( $caller );
  TUI::Objects::Rect->unimport::out_of( $caller );
  TUI::Objects::NSCollection->unimport::out_of( $caller );
  TUI::Objects::NSSortedCollection->unimport::out_of( $caller );
  TUI::Objects::Collection->unimport::out_of( $caller );
  TUI::Objects::SortedCollection->unimport::out_of( $caller );
  TUI::Objects::StringCollection->unimport::out_of( $caller );
}

1

__END__

=pod

=head1 NAME

TUI::Objects - Base object classes for the TUI::Vision framework

=head1 SYNOPSIS

  use TUI::Objects;

=head1 DESCRIPTION

TUI::Objects provides the foundational object layer for the TUI::Vision
framework. It corresponds to the classic Turbo Vision TObject system and
serves as the central hub for all structural classes, including:

=over 4

=item * Object base class  
Lifecycle, ownership, and common behavior.

=item * Geometry classes  
Point, Rect, and related utilities.

=item * Collection classes  
Typed and sorted collections, mirroring the original TVision design.

=item * Constants and shared definitions  
Symbolic constants used throughout the framework.

=back

In the original TV:: namespace, this module re-exported multiple
submodules (Object, Point, Rect, Collection, SortedCollection, etc.)
via C<import> and C<unimport>.

=head1 AUTHORS

=over

=item Borland International (original Turbo Vision design)

=item J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 CONTRIBUTORS

Contributors are documented in the POD of the respective framework modules.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 1990-1994, 1997 by Borland International

Copyright (c) 2021-2026 the L</AUTHORS> as listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut

