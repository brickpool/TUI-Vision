package TUI::Drivers::ScreenCell;
# ABSTRACT: screen cell value type

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TScreenCell
);

use PerlX::Assert::PP;
use Scalar::Util qw(
  blessed
  looks_like_number
);

use TUI::Drivers::ColorAttr;
use TUI::Drivers::CellChar;

sub TScreenCell() { __PACKAGE__ }

sub new {    # $cell (|%args)
  my ( $class, @args ) = @_;
  assert ( $class and !ref $class );

  # TScreenCell()
  return bless [
    TColorAttr->new(),
    TCellChar->new(),
  ], $class unless @args;

  # TScreenCell( bios => Int )
  if ( @args == 2 && $args[0] eq 'bios' ) {
    assert ( looks_like_number $args[1] );
    my $bios = $args[1];
    my $attr = ( $bios >> 8 ) & 0xff;
    my $ch = $bios & 0xff;
    return bless [
      TColorAttr->new( bios => $attr ),
      TCellChar->new( text => $ch ),
    ], $class;
  }

  return;
}

sub isWide {    # $bool ()
  assert ( blessed $_[0] );
  return $_[0]->[1]->isWide;
}

sub equals {    # $bool ($other)
  my ( $self, $other ) = @_;
  assert ( blessed $self );
  assert ( blessed $other );
  return ref $self eq ref $other
      && ${ $self->[0] } == ${ $other->[0] }
      && ${ $self->[1] } eq ${ $other->[1] };
}

use overload
  '==' => \&equals,
  fallback => 1;

sub getAttr {    # $attr ()
  assert ( blessed $_[0] );
  return $_[0]->[0];
}

sub getChar {    # $ch ()
  assert ( blessed $_[0] );
  return $_[0]->[1];
}

sub setAttr {    # void ($attr)
  my ( $cell, $attr ) = @_;
  assert ( blessed $cell );
  assert ( blessed $attr );

  $cell->[0] = $attr;
  return;
}

sub setChar {    # void ($ch)
  my ( $cell, $ch ) = @_;
  assert ( blessed $cell );
  assert ( blessed $ch or !ref $ch && length $ch );

  $cell->[1] = ref( $ch )
             ? $ch
             : TCellChar->new( text => $ch );
  return;
}

sub setCell {    # void ($ch, $attr)
  my ( $cell, $ch, $attr ) = @_;
  $cell->setChar( $ch );
  $cell->setAttr( $attr );
  return;
}

1;

=head1 NAME

TScreenCell - screen cell value type

=head1 SYNOPSIS

  use TUI::Drivers;

  my $cell = TScreenCell->new(
    bios => 0x1F,
  );

  $cell->setChar( 'A' );

  my $attr = $cell->getAttr;
  my $ch   = $cell->getChar;

=head1 DESCRIPTION

C<TScreenCell> stores the character and color attributes associated with
a screen cell.

A screen cell consists of:

=over

=item *

a C<TColorAttr> value describing the cell attributes

=item *

a C<TCellChar> value describing the cell contents

=back

Double-width characters occupy two adjacent screen cells. The first cell
contains the character itself and the second cell contains a wide-character
trail placeholder.

If a double-width character is not followed by a wide-character trail, or
if a wide-character trail is not preceded by a double-width character, the
character is considered to be partially overwritten.

=head1 CONSTRUCTOR

=head2 new

Creates a screen cell.

  my $cell = TScreenCell->new();

Construct a cell using default attributes and an empty character value:

  my $cell = TScreenCell->new( bios => 0x1F );

Construct a cell using a BIOS color attribute:

=head1 METHODS

=head2 equals

 my $bool = $self->equals($other);

Returns true if both screen cells contain identical character and
attribute values.

=head2 getAttr

 my $attr = $self->getAttr();

Returns the C<TColorAttr> associated with the cell.

=head2 getChar

 my $ch = $self->getChar();

Returns the C<TCellChar> stored in the cell.

=head2 isWide

 my $bool = $self->isWide();

Returns true if the stored character does not occupy exactly one screen
column.

=head2 setAttr

 $self->setAttr($attr);

Sets the cell attributes.

=head2 setCell

  $cell->setCell($char, $attr);

Sets both the character and the attributes of the cell.

=head2 setChar

 $self->setChar($ch);

Sets the character stored in the cell.

=head1 SEE ALSO

L<TCellChar|TUI::Drivers::CellChar>,
L<TColorAttr|TUI::Drivers::ColorAttr>

=head1 AUTHORS

=over

=item * magiblot <magiblot@hotmail.com> (original screen cell design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2019-2026 the L</AUTHORS> listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut
