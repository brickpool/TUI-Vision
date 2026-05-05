package TUI::TextView;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::TextView::TextDevice;
use TUI::TextView::Terminal;

sub import {
  my $target = caller;
  TUI::TextView::TextDevice->import::into( $target );
  TUI::TextView::Terminal->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::TextView::TextDevice->unimport::out_of( $caller );
  TUI::TextView::Terminal->unimport::out_of( $caller );
}

1

__END__

=pod

=head1 NAME

TUI::TextView - Text rendering components for the TUI::Vision framework

=head1 SYNOPSIS

  use TUI::TextView;

=head1 DESCRIPTION

TUI::TextView provides the text rendering subsystem for the TUI::Vision
framework. It corresponds to the Turbo Vision text device and terminal
abstraction layers and is responsible for low-level text output,
character cell handling, and terminal interaction.

This module re-exported:

=over 4

=item * TextDevice  
A low-level abstraction for text output devices.

=item * Terminal  
Terminal-specific rendering and control sequences.

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

Copyright (c) 2025-2026 the L</AUTHORS> as listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut
