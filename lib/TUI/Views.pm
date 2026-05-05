package TUI::Views;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Views::Const;
use TUI::Views::CommandSet;
use TUI::Views::DrawBuffer;
use TUI::Views::Palette;
use TUI::Views::View;
use TUI::Views::Group;
use TUI::Views::Frame;
use TUI::Views::ListViewer;
use TUI::Views::ScrollBar;
use TUI::Views::WindowInit;
use TUI::Views::Window;
use TUI::Views::Util;

sub import {
  my $target = caller;
  TUI::Views::Const->import::into( $target, qw( :all ) );
  TUI::Views::CommandSet->import::into( $target );
  TUI::Views::DrawBuffer->import::into( $target );
  TUI::Views::Palette->import::into( $target );
  TUI::Views::View->import::into( $target );
  TUI::Views::Group->import::into( $target );
  TUI::Views::Frame->import::into( $target );
  TUI::Views::ListViewer->import::into( $target );
  TUI::Views::ScrollBar->import::into( $target );
  TUI::Views::WindowInit->import::into( $target );
  TUI::Views::Window->import::into( $target );
  TUI::Views::Util->import::into( $target, qw( message ) );
}

sub unimport {
  my $caller = caller;
  TUI::Views::Const->unimport::out_of( $caller );
  TUI::Views::CommandSet->unimport::out_of( $caller );
  TUI::Views::DrawBuffer->unimport::out_of( $caller );
  TUI::Views::Palette->unimport::out_of( $caller );
  TUI::Views::View->unimport::out_of( $caller );
  TUI::Views::Group->unimport::out_of( $caller );
  TUI::Views::Frame->unimport::out_of( $caller );
  TUI::Views::ListViewer->unimport::out_of( $caller );
  TUI::Views::ScrollBar->unimport::out_of( $caller );
  TUI::Views::WindowInit->unimport::out_of( $caller );
  TUI::Views::Window->unimport::out_of( $caller );
  TUI::Views::Util->unimport::out_of( $caller );
}

1

__END__

=pod

=head1 NAME

TUI::Views - Core view classes for the TUI::Vision framework

=head1 SYNOPSIS

  use TUI::Views;

=head1 DESCRIPTION

TUI::Views provides the core view and windowing subsystem for the
TUI::Vision framework. It corresponds to the Turbo Vision view
architecture and includes all fundamental UI components such as views,
groups, frames, windows, palettes, and drawing buffers.

This module re-exported a wide range of view-related classes, including:

=over 4

=item * Const  
Symbolic constants for view behavior.

=item * CommandSet  
Command and hotkey definitions.

=item * DrawBuffer  
Low-level drawing buffer for character cell output.

=item * Palette  
Color palette definitions.

=item * View  
Base class for all visual components.

=item * Group  
Container for child views.

=item * Frame  
Window frame and border rendering.

=item * ListViewer  
Scrollable list view.

=item * ScrollBar  
Vertical and horizontal scroll bars.

=item * WindowInit / Window  
Window initialization and window objects.

=item * Util  
Utility functions such as C<message>.

=back

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
