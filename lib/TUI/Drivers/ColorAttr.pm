package TUI::Drivers::ColorAttr;
# ABSTRACT: color attribute value type for screen cells

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TColorAttr
);

use PerlX::Assert::PP;
use Scalar::Util qw(
  blessed
  looks_like_number
);

use TUI::Drivers::Const qw( :slXXXX );
use TUI::Drivers::ColorDesired;

sub TColorAttr() { __PACKAGE__ }

sub new {    # $attr (|%args)
  my ( $class, @args ) = @_;

  # TColorAttr->new()
  my $v;
  if ( !@args ) {
    $v = 0;
  }

  # TColorAttr->new( bios => Int )
  elsif ( @args == 2 && $args[0] eq 'bios' ) {
    my $bios = $args[1] & 0xff;
    assert ( looks_like_number $bios );

    my $fg = TColorDesired->new( bios => $bios & 0xf )->bitCast();
    my $bg = TColorDesired->new( bios => $bios >> 4 )->bitCast();

    $v = ( ( $fg & 0x7ffffff ) << 10 )
       | ( ( $bg & 0x7ffffff ) << 37 );
  }

  # TColorAttr->new(
  #   fg => TColorDesired,
  #   bg => TColorDesired,
  #   | style => Int
  # )
  elsif ( @args % 2 == 0 ) {
    my %args = @args;

    my $style = $args{style} // 0;
    my $fg = $args{fg};
    my $bg = $args{bg};

    assert ( looks_like_number $style );
    assert ( blessed $fg );
    assert ( blessed $bg );

    $v = ( $style & 0x3ff ) 
       | ( ( $fg->bitCast & 0x7ffffff ) << 10 )
       | ( ( $bg->bitCast & 0x7ffffff ) << 37 );
  }

  else {
    return;
  }
  
  return bless \$v, $class;
} #/ sub new

sub isBIOS {    # $bool ()
  my ( $self ) = @_;
  assert ( blessed $self );
  return $self->getFore->isBIOS() 
      && $self->getBack->isBIOS() 
      && !$self->getStyle();
}

# Quantization
sub toBIOS {    # $attr ()
  my ( $self ) = @_;
  assert ( blessed $self );
  my $fg = $self->getFore();
  my $bg = $self->getBack();
  return ( $fg->toBIOS( 1 ) | ( $bg->toBIOS( 0 ) << 4 ) ) & 0xff;
}

# Result is meaningful only if it actually is BIOS.
sub asBIOS {    # $attr ()
  my ( $self ) = @_;
  assert ( blessed $self );

  # $$self must be a BIOS attribute. If it is not, the result will be
  # bogus but harmless. The important is that the result isn't \x0
  # unless this is BIOS attribute \x0.
  my $fg = ( ${$self} >> 10 ) & 0x0f;
  my $bg = ( ${$self} >> 37 ) & 0x0f;
  my $bios = $fg | ( $bg << 4 );
  return $self->isBIOS ? $bios : 0x5f;
}

sub equals {    # $bool ($other|$bios)
  my ( $self, $other ) = @_;
  assert ( blessed $self );
  assert ( blessed $other or looks_like_number $other );
  return ref $other
    ? $$self == $$other 
    : $self->asBIOS == $other;
}

use overload
  '0+' => \&asBIOS,
  '==' => \&equals,
  fallback => 1;

sub getFore {    # $fg ()
  assert ( blessed $_[0] );
  my $color = TColorDesired->new();
  $color->bitCast( ( ${ $_[0] } >> 10 ) & 0x7ffffff );
  return $color;
}

sub getBack {    # $bg ()
  assert ( blessed $_[0] );
  my $color = TColorDesired->new();
  $color->bitCast( ( ${ $_[0] } >> 37 ) & 0x7ffffff );
  return $color;
}

sub getStyle {    # sytle ()
  assert ( blessed $_[0] );
  return ${ $_[0] } & 0x3ff;
}

sub setFore {    # void ($color)
  my ( $self, $color ) = @_;
  assert( blessed $self );
  assert( blessed $color );
  ${$self} = ( ${$self} & ~( 0x7ffffff << 10 ) )
           | ( ( $color->bitCast & 0x7ffffff ) << 10 );
  return;
}

sub setBack {    # void ($color)
  my ( $self, $color ) = @_;
  assert( blessed $self );
  assert( blessed $color );
  ${$self} = ( ${$self} & ~( 0x7ffffff << 37 ) )
           | ( ( $color->bitCast & 0x7ffffff ) << 37 );
  return;
}

sub setStyle {    # void ($style)
  my ( $self, $style ) = @_;
  assert( blessed $self );
  assert( looks_like_number $style );
  ${$self} = ( ${$self} & ~0x3ff )
           | ( $style & 0x3ff );
  return;
}

sub reverseAttribute {    # $attr ()
  my ( $self ) = @_;
  my $fg = $self->getFore();
  my $bg = $self->getBack();
  # The 'slReverse' attribute is represented differently by every terminal,
  # so it is better to swap the colors manually unless any of them is default.
  if ( $fg->isDefault() || $bg->isDefault() ) {
    $self->setStyle( $self->getStyle() ^ slReverse );
  }
  else {
    $self->setFore( $bg );
    $self->setBack( $fg );
  }
  return $self;
}

1;

__END__

=head1 NAME

TColorAttr - color attribute value type for screen cells

=head1 SYNOPSIS

  use TUI::Drivers;

  my $attr = TColorAttr->new(
    bios => 0x3D,
  );

  my $bios = $attr->asBIOS;

=head1 DESCRIPTION

C<TUI::Drivers::ColorAttr> provides C<TColorAttr>, a value type that
represents the color attributes of a screen cell.

A C<TColorAttr> stores foreground color, background color, and style
information. It can also represent traditional BIOS color attributes used
by Turbo Vision color handling.

=head1 CONSTRUCTOR

=head2 new

Creates a color attribute value.

With no arguments, the value uses default colors and no style flags:

  my $attr = TColorAttr->new();

With a BIOS color attribute:

  my $attr = TColorAttr->new(
    bios => 0x3D,
  );

With explicit foreground, background, and optional style information:

  my $attr = TColorAttr->new(
    fg    => $fg,
    bg    => $bg,
    style => $style,
  );

The C<$fg> and C<$bg> arguments must be a C<TColorDesired> values.

=head1 METHODS

=head2 asBIOS

 my $attr = $self->asBIOS();

Returns a BIOS color attribute equivalent to the current value.

The result is meaningful only when C<isBIOS> returns true.

=head2 getBack

 my $bg = $self->getBack();

Returns the background color component.

=head2 getFore

 my $fg = $self->getFore();

Returns the foreground color component.

=head2 getStyle

 my sytle = $self->getStyle();

Returns the style flags component.

=head2 isBIOS

 my $bool = $self->isBIOS();

Returns true if this value is represented as a BIOS color attribute.

=head2 reverseAttribute

  my $attr = $self->reverseAttribute();

Reverses the visual foreground and background colors.

The C<slReverse> style attribute is interpreted differently by different
terminal implementations. Therefore, explicit foreground and background colors
are swapped whenever possible.

If either color is the terminal default color, the color values are left
unchanged and the C<slReverse> style flag is toggled instead.

Returns C<$self>.

=head2 setFore

  $self->setFore($color);

Sets the foreground color component.

The argument must be a C<TColorDesired> value.

=head2 setBack

  $self->setBack($color);

Sets the background color component.

The argument must be a C<TColorDesired> value.

=head2 setStyle

  $self->setStyle($style);

Sets the style flags component.

Only the style bits defined by the C<TColorAttr> representation are stored.

=head2 toBIOS

 my $attr = $self->toBIOS();

Returns a BIOS color attribute for this value.

=head1 OPERATORS

=head2 Numeric equality

  $a == $b

Returns true when C<TColorDesired> values contain identical data; support 
typecast of C<$b> to a BIOS value if it is a number.

=head2 Numeric conversion

  my $bios = 0+ $a;

Returns the BIOS color attribute equivalent to this value.

=head1 SEE ALSO

L<TUI::Drivers::Const>,
L<TColorDesired|TUI::Drivers::ColorDesired>,
L<TScreenCell|TUI::Drivers::ScreenCell>

=head1 AUTHORS

=over

=item * magiblot <magiblot@hotmail.com> (original color attribute design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2019-2026 the L</AUTHORS> listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut
