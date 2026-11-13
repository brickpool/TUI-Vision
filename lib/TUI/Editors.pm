package TUI::Editors;
# ABSTRACT: Editor-related modules for the framework

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000002';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Editors::Const;
use TUI::Editors::Indicator;

sub import {
  my $target = caller;
  TUI::Editors::Const->import::into( $target, qw( :all ) );
  TUI::Editors::Indicator->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::Editors::Const->unimport::out_of( $caller );
  TUI::Editors::Indicator->unimport::out_of( $caller );
}

1

__END__

=head1 NAME

TUI::Editors - Editor components for the TUI::Vision framework

=head1 SYNOPSIS

  use TUI::Objects;
  use TUI::Editors;

  # Typical indicator setup inside a TApplication/TProgram subclass:
  my $indicator = TIndicator->new(
    bounds => TRect->new( ax => 0, ay => 23, bx => 80, by => 24 ),
  );

  $self->insert($indicator);

  # Update the displayed cursor position and modified flag
  $indicator->setValue( TPoint->new( x => 0, y => 0 ), !!0 );

=head1 DESCRIPTION

C<TUI::Editors> provides the editor components for the TUI::Vision framework.
These modules are compatible with the editor subsystem of the classic
I<Turbo Vision> framework where practical.

This module re-exports the following components:

=over 4

=item * L<Const|TUI::Editors::Const> -
Symbolic constants for editor behavior.

=item * L<TIndicator|TUI::Editors::Indicator> -
A view that displays the cursor position and modified state of an editor.

=back

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
