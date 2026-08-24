package TUI::Drivers::CellChar;
# ABSTRACT: character value type for screen cells

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TCellChar
);

require bytes;
use PerlX::Assert::PP;
use Scalar::Util qw( blessed );
use Terminal::WCWidth qw( wcswidth );

sub TCellChar() { __PACKAGE__ }

sub new {    # $cch (|%args)
  my ( $class, @args ) = @_;
  assert ( $class and !ref $class );

  # TCellChar->new()
  my $text;
  if ( !@args ) {
    $text = '';
  }

  # TCellChar->new( text => Str )
  elsif ( @args == 2 && $args[0] eq 'text' ) {
    $text = $args[1];
    assert ( !ref $text and length $text );
  }

  else {
    return;
  }

  return bless \$text, $class;
}

sub moveChar {    # void ($ch)
  my ( $self, $ch ) = @_;
  assert( blessed $self );
  assert( !ref $ch );
  assert( bytes::length($ch) == 1 );
  ${$self} = $ch;
  return;
}

sub moveMultiByteChar {    # void ($text)
  my ( $self, $text ) = @_;
  assert( blessed $self );
  assert( !ref $text );
  ${$self} = $text;
  return;
}

sub moveWideCharTrail {    # void ()
  assert( blessed $_[0] );
  ${ $_[0] } = "\0";
  return;
}

sub isWide {    # $bool ()
  assert ( blessed $_[0] );
  my $text = ${ $_[0] };
  return !!0
    if bytes::length( $text ) <= 1;
  return wcswidth( ${ $_[0] } ) >= 2;
}

sub isWideCharTrail {    # $bool ()
  assert ( blessed $_[0] );
  return ${ $_[0] } eq "\0";
}

sub appendZeroWidthChar {    # void ($mbc)
  my ( $self, $mbc ) = @_;
  assert( blessed $self );
  assert( !ref $mbc );
  ${$self} .= $mbc;
  return;
}

sub getText {    # $ch ()
  assert ( blessed $_[0] );
  my $text = ${ $_[0] };
  return length( $text ) ? $text : "\0";
}

sub size {    # $bytes ()
  assert ( blessed $_[0] );
  # There is always at least one character, even if it is a NUL
  return bytes::length( ${ $_[0] } ) || 1;
}

1;

__END__

=head1 NAME

TCellChar - character value type for screen cells

=head1 SYNOPSIS

  use TUI::Drivers;

  my $ch = TCellChar->new(
    text => 'A',
  );

  my $text = $ch->getText;

=head1 DESCRIPTION

C<TCellChar> represents the text stored in a single screen cell.

A cell may contain:

=over

=item *

A single-byte ASCII or extended ASCII character.

=item *

A UTF-8 character or character sequence occupying one or two screen columns.

=item *

A special wide-character trail marker representing the trailing cell of a wide
character.

=back

The stored text always contains a visible character, unless the value
represents a wide-character trail marker. Zero-width Unicode characters may
therefore only appear as part of a character sequence attached to a visible
base character.

Wide-character trail markers are internal placeholders used to represent the
additional screen cell occupied by a wide character. They do not contribute
visible text of their own.

Applications may construct and manipulate C<TCellChar> values directly, but
screen text is usually written through the functions provided by
L<TText|TUI::Drivers::Text>.

=head1 CONSTRUCTOR

=head2 new

Creates a new character value.

Construct an empty value:

  my $ch = TCellChar->new();

Construct from text:

  my $ch = TCellChar->new(
    text => 'A',
  );

Construct a wide-character trail placeholder:

  my $trail = TCellChar->new(
    text => "\0",
  );

=head1 METHODS

=head2 appendZeroWidthChar

  $self->appendZeroWidthChar($text);

Appends a zero-width Unicode character sequence to the stored text.

The resulting value continues to represent a single screen cell and must still 
contain at least one visible character.

=head2 getText

 my $ch = $self->getText();

Returns the stored text.

=head2 isWide

 my $bool = $self->isWide();

Returns true if the stored text does not occupy exactly one screen column.

=head2 isWideCharTrail

 my $bool = $self->isWideCharTrail();

Returns true if the value represents a wide-character trail placeholder.

=head2 moveChar

  $self->moveChar($ch);

Replaces the stored text with a single-byte character.

=head2 moveMultiByteChar

  $self->moveMultiByteChar($text);

Replaces the stored text with a UTF-8 character or character sequence.

The resulting value may occupy one or two screen columns.

=head2 moveWideCharTrail

  $self->moveWideCharTrail();

Replaces the stored text with a special wide-character trail marker.

This value is used internally as the trailing cell occupied by a wide character.

=head2 size

 my $bytes = $self->size();

Returns the length of the stored text.

=head1 SEE ALSO

L<TScreenCell|TUI::Drivers::ScreenCell>,
L<TColorAttr|TUI::Drivers::ColorAttr>

=head1 AUTHORS

=over

=item * magiblot <magiblot@hotmail.com> (original cell char design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2019-2026 the L</AUTHORS> listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut
