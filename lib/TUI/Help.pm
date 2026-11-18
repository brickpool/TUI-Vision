package TUI::Help;
# ABSTRACT: Help-related modules for the framework

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000002';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Help::HelpBase;
use TUI::Help::RefTable;
use TUI::Help::TopicDefinition;
use TUI::Help::HelpTopic;
use TUI::Help::HelpIndex;

sub import {
  my $target = caller;
  TUI::Help::RefTable->import::into( $target );
  TUI::Help::TopicDefinition->import::into( $target );
  TUI::Help::HelpTopic->import::into( $target );
  TUI::Help::HelpIndex->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::Help::RefTable->unimport::out_of( $caller );
  TUI::Help::TopicDefinition->unimport::out_of( $caller );
  TUI::Help::HelpTopic->unimport::out_of( $caller );
  TUI::Help::HelpIndex->unimport::out_of( $caller );
}

1

__END__

=head1 NAME

TUI::Help - Help-related modules for the framework

=head1 SYNOPSIS

  use TUI::Help;

  my $table = new_TRefTable( 10, 5 );
  my $reference = $table->getReference( 'Introduction' );

=head1 DESCRIPTION

C<TUI::Help> provides help-related view classes and functionality for the 
L<TUI::Vision> framework.

The module loads L<THelpBase|TUI::Help::HelpBase>, making its C<TParagraph>,
C<TCrossRef>, and C<TReference> records available.

This module re-exports the following modules:

=over 4

=item * L<TRefTable|TUI::Help::RefTable>
Sorted symbol table of topic references, including C<TRefTable> and
C<new_TRefTable>.

=item * L<THelpIndex|TUI::Help::HelpIndex>
Help context position index, including C<THelpIndex> and C<new_THelpIndex>.

=item * L<TTopicDefinition|TUI::Help::TopicDefinition>
Linked topic definition, including C<TTopicDefinition> and
C<new_TTopicDefinition>.

=item * L<THelpTopic|TUI::Help::HelpTopic>
Paragraph text, wrapping, and cross-references, including C<THelpTopic>
and C<new_THelpTopic>, with C<Storable> persistence.

=back

The remaining help classes are currently skeletons and are not loaded or
re-exported by this module.

Help related views are responsible for displaying and managing help content 
within the framework's user interface and are intended to provide behavior 
compatible with the original I<Turbo Vision> help system where practical.

=head1 COMPATIBILITY

The design of the help subsystem is inspired by Borland I<Turbo Vision> help 
framework. Behavior, naming conventions, and APIs may therefore resemble 
their original I<Turbo Vision> counterparts where appropriate for the Perl 
implementation.

=head1 AUTHORS

=over

=item * Borland International (original Turbo Vision design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 1990-1994, 1997 by Borland International

Copyright (c) 2026 the L</AUTHORS> as listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).
