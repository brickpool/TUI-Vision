package TUI::Views::DrawBuffer;
# ABSTRACT: TDrawBuffer stores a line of text for output in views

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TDrawBuffer
  new_TDrawBuffer
);

use List::Util qw( min max );
use TUI::toolkit qw( :utils );
use TUI::toolkit::Types qw(
  :is
  :types
  Maybe
);

use TUI::Drivers::ScreenCell;
use TUI::Drivers::Screen;
use TUI::Views::Const qw( maxViewWidth );

sub TDrawBuffer() { __PACKAGE__ }
sub new_TDrawBuffer { __PACKAGE__->from(@_) }

# import global variables
use vars qw(
  $screenHeight
  $screenWidth
);
{
  no strict 'refs';
  *screenHeight = \${ TScreen . '::screenHeight' };
  *screenWidth  = \${ TScreen . '::screenWidth' };
}

# The following subroutine was ported from the framework
# "A modern port of Turbo Vision 2.0", which is licensed under MIT licence.
#
# Copyright 2019-2021 by magiblot <magiblot@hotmail.com>
#
# I<drivers.cpp>
#
my $allocData = sub {    # \@data ()
  assert ( @_ == 0 );
  # This makes it possible to create TDrawBuffers for screens wider than 
  # 'maxViewWidth'. 
  # We must take the greatest of the screen's dimensions, because we cannot 
  # assume that 'screenWidth > screenHeight' and TDrawBuffer can also be used 
  # to draw vertical views (e.g. TScrollBar).
  # In addition, give some room for views that might exceed the screen size.
  my $len = max( 8 + max( $screenWidth, $screenHeight ), maxViewWidth );
  return [ map { TScreenCell->new() } 1 .. $len ];
};

sub new {    # $obj ()
  state $sig = signature(
    method => 1,
    pos    => [],
  );
  my ( $class ) = $sig->( @_ );
  my $self  = &$allocData();
  return bless $self, $class;
}

sub from {    # $obj ()
  goto &new;
}

sub putAttribute {    # void ($indent, $attr)
  state $sig = signature(
    method => Object,
    pos    => [
      PositiveOrZeroInt, 
      sub { is_Object $_[0] or is_PositiveOrZeroInt $_[0] }, 
    ],
  );
  my ( $self, $indent, $attr ) = $sig->( @_ );
  $self->[$indent]->setAttr( $attr );
  return;
}

sub putChar {    # void ($indent, $c)
  state $sig = signature(
    method => Object,
    pos    => [PositiveOrZeroInt, Str],
  );
  my ( $self, $indent, $c ) = $sig->( @_ );
  assert ( length $c );
  $self->[$indent]->setChar( $c );
  return;
}

sub moveBuf {    # void ($indent, \@source, $attr|undef, $count)
  state $sig = signature(
    method => Object,
    pos    => [
      PositiveOrZeroInt, 
      ArrayLike, 
      sub { !defined $_[0] or is_Object $_[0] or is_PositiveOrZeroInt $_[0] }, 
      PositiveOrZeroInt,
    ],
  );
  my ( $self, $indent, $source, $attr, $count ) = $sig->( @_ );

  if ( defined $attr ) {
    for ( my $i = 0 ; $i < $count ; $i++ ) {
      my $c = $source->[$i]; 
      $self->[ $indent + $i ]->setCell(
        ref $c ? $c->getChar() : chr( $c ),
        $attr,
      );
    }
  }
  else {
    for ( my $i = 0 ; $i < $count ; $i++ ) {
      if ( ref ( my $c = $source->[$i] ) ) {
        $self->[ $indent + $i ]->setCell(
          $c->getChar(),
          $c->getAttr(),
        );
      }
      else {
        my ( $ch, $attr ) = unpack 'aC' => pack 'v' => $c;
        $self->[ $indent + $i ]->setCell( $ch,  $attr );
      }
    }
  }
  return;
} #/ sub moveBuf

sub moveChar {    # void ($indent, $c|undef, $attr|undef, $count)
  state $sig = signature(
    method => Object,
    pos    => [
      PositiveOrZeroInt, 
      Maybe[Str], 
      sub { !defined $_[0] or is_Object $_[0] or is_PositiveOrZeroInt $_[0] }, 
      PositiveOrZeroInt,
    ],
  );
  my ( $self, $indent, $c, $attr, $count ) = $sig->( @_ );

  my $dest = $indent;
  $count = min( $count, max( scalar( @$self ) - $indent, 0 ) );

  if ( defined $attr ) {
    if ( defined $c ) {
      $self->[ $dest++ ]->setCell( $c, $attr )
        for 1 .. $count;
    } 
    else {
      $self->[ $dest++ ]->setAttr( $attr )
        for 1 .. $count;
    }
  }
  else {
    assert ( length $c );
    $self->[ $dest++ ]->setChar( $c )
      for 1 .. $count;
  }
  return;
} #/ sub moveChar

sub moveCStr {    # $num ($indent, $str, $attrs)
  state $sig = signature(
    method => Object,
    pos    => [
      PositiveOrZeroInt, 
      Str, 
      sub { is_ArrayLike $_[0] or is_PositiveOrZeroInt $_[0] }, 
    ],
  );
  my ( $self, $indent, $str, $attrs ) = $sig->( @_ );

  my $dest   = $indent;
  my $limit  = @$self;
  my $toggle = 1;
  $attrs = [ $attrs & 0xff, ( $attrs >> 8 ) & 0xff ] unless ref $attrs;
  my $curAttr = $attrs->[0];

  foreach my $c ( split //, $str ) {
    last unless $dest < $limit;
    if ( $c eq '~' ) {
      $curAttr = $attrs->[$toggle];
      $toggle  = 1 - $toggle;
    }
    else {
      $self->[ $dest++ ]->setCell( $c, $curAttr );
    }
  }
  return $dest - $indent;
} #/ sub moveCStr

sub moveStr {    # $num ($indent, $str, $attr|undef)
  state $sig = signature(
    method => Object,
    pos    => [
      PositiveOrZeroInt, 
      Str, 
      sub { !defined $_[0] or is_Object $_[0] or is_PositiveOrZeroInt $_[0] }, 
    ],
  );
  my ( $self, $indent, $str, $attr ) = $sig->( @_ );

  return 0 
    unless $indent < @$self;

  my $dest = $indent;
  my $count = min( length $str, scalar( @$self ) - $indent );

  if ( defined $attr ) {
    $self->[ $dest++ ]->setCell( $_, $attr )
      for split //, $str;
  }
  else {
    $self->[ $dest++ ]->setChar( $_ )
      for split //, $str;
  }
  return $count;
}

1

__END__

=pod

=head1 NAME

TDrawBuffer - temporary line buffer for screen output

=head1 HIERARCHY

  TDrawBuffer (value type)
    used by TView drawing methods

=head1 SYNOPSIS

  use TUI::Views;

  my $buffer = TDrawBuffer->new;

  $buffer->moveStr(
    0,
    'Financial Results for FY1991',
    $view->getColor(1)
  );

  $view->writeLine(1, 3, 28, 1, $buffer);

=head1 DESCRIPTION

C<TDrawBuffer> represents a temporary buffer for rendering a single line of
screen output. Each entry in the buffer stores both a character value and a
display attribute.

This type is a lightweight value type and is not derived from C<TObject>.
Internally, it corresponds to an array of fixed width, where each element
combines a character and its visual attributes.

C<TDrawBuffer> is primarily used inside C<TView> drawing routines. Text and
attributes are written into the buffer using helper methods, and the buffer is
then passed to C<TView> methods such as C<writeLine> or C<writeBuf> to render 
the output on screen.

=head1 CONSTRUCTOR

=head2 new

  my $buffer = TDrawBuffer->new();

Creates a new, empty draw buffer with a width equal to the maximum view width.

=head1 METHODS

=head2 moveBuf

  $buffer->moveBuf($indent, \@source, $attr | undef, $count);

Copies character data from C<@source> into the draw buffer.

Source elements may be Unicode codepoints, legacy packed screen-cell
values (C<short>), or C<TScreenCell> objects.

If C<$attr> is defined, it overrides any attribute information present
in the source data.

Otherwise, attribute information is taken from the source element when
available (either from a legacy packed screen-cell value or from a
C<TScreenCell> object).

=head2 moveChar

  $buffer->moveChar($indent, $char | undef, $attr | undef, $count);

Writes a repeated character (C<undef> to retain the already present characters) 
into the buffer using the given attribute (C<undef> to retain the already 
present attributes).

B<Note:> If both C<$char> and C<$attr> are C<undef>, the attributes are 
retained but the characters are not.

=head2 moveCStr

  my $num = $buffer->moveCStr($indent, $string, $attrs);

Writes a string containing Turbo Vision style tilde markers into the buffer,
applying the specified attributes.

Returns the number of cells in the buffer that were actually updated.

=head2 moveStr

  my $num = $buffer->moveStr($indent, $string, $attr | undef);

Writes a plain string into the buffer starting at the specified position and
applies the given attributes.

Returns the number of cells in the buffer that were actually updated.

=head2 putAttribute

  $buffer->putAttribute($index, $attr);

Sets the display attribute at the specified buffer position.

=head2 putChar

  $buffer->putChar($index, $char);

Sets the character value at the specified buffer position.

=head1 SEE ALSO

L<TView|TUI::Views::View>,
L<TWindow|TUI::Views::Window>

=head1 AUTHORS

=over

=item * Borland International (original Turbo Vision design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 CONTRIBUTORS

=over

=item * magiblot <magiblot@hotmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 1990-1994, 1997 by Borland International

Copyright (c) 2019-2026 the L</AUTHORS> and L</CONTRIBUTORS> as listed above.

This software is licensed under the MIT license (see the LICENSE file, which is 
part of the distribution).

=cut
