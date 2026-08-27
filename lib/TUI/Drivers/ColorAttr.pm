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
use TUI::Drivers::Color;

sub TColorAttr() { __PACKAGE__ }

my $coerceColor = sub {
  my ( $value ) = @_;

  # Already TColor.
  return $value if blessed $value;

  # {} -> default
  if ( ref $value eq 'HASH' ) {
    return TColor->new( %$value );
  }

  # [] -> Abbreviations
  if ( ref $value eq 'ARRAY' ) {

    # []
    return TColor->new()
      unless @$value;

    # ['\x7'], ['\x07'], ['\x{07}']
    if ( @$value == 1
      && !ref( $value->[0] )
      && $value->[0] =~ /^\\x(?:\{([[:xdigit:]]+)\}|([[:xdigit:]]{1,2}))$/ )
    {
      return TColor->new(
        bios => hex( $1 // $2 ),
      );
    }

    # ['\007'], ['\o{007}']
    if ( @$value == 1
      && !ref( $value->[0] )
      && $value->[0] =~ /^\\(?:o\{([0-7]+)\}|([0-7]{1,3}))$/
    ) {
      return TColor->new(
        bios => oct( $1 // $2 ),
      );
    }

    # ['0b0111']
    if ( @$value == 1
      && !ref( $value->[0] )
      && $value->[0] =~ /^(0b[01]{4})$/ )
    {
      return TColor->new(
        bios => oct( $1 ),
      );
    }

    # [196]
    if ( @$value == 1 && looks_like_number( $value->[0] ) ) {
      return TColor->new(
        xterm => $value->[0],
      );
    }
    # ["\x7"]: a single already-resolved byte (e.g. from a double-quoted
    # escape) is read directly as a BIOS value via its ordinal. Only
    # printable digits ('0'..'9') are excluded, as those are already
    # handled above as xterm indices.
    if ( @$value == 1
      && !ref( $value->[0] )
      && length( $value->[0] ) == 1
    ) {
      return TColor->new(
        bios => ord( $value->[0] ),
      );
    }
    # ['#7fbb00'] (rgb8, one byte per channel)
    if ( @$value == 1
      && !ref( $value->[0] )
      && $value->[0] =~ /^#([[:xdigit:]]{6})$/
    ) {
      return TColor->new(
        rgb => hex( $1 ),
      );
    }

    # ['#7fb'] (shorthand, each digit doubled)
    if ( @$value == 1
      && !ref( $value->[0] )
      && $value->[0] =~ /^#([[:xdigit:]])([[:xdigit:]])([[:xdigit:]])$/
    ) {
      return TColor->new(
        rgb => hex( "$1$1$2$2$3$3" ),
      );
    }

    # [127,0,187]
    if ( @$value == 3 ) {
      return TColor->new(
        rgb => $value,
      );
    }
  } #/ if ( ref( $value ) eq ...)

  return;
};

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

    my $fg = TColor->new( bios => $bios & 0xf );
    my $bg = TColor->new( bios => $bios >> 4 );

    $v = ( ( $fg & 0x7ffffff ) << 10 )
       | ( ( $bg & 0x7ffffff ) << 37 );
  }

  # TColorAttr->new(
  #   fg => TColor,
  #   bg => TColor,
  #   | style => Int
  # )
  elsif ( @args % 2 == 0 ) {
    my %args = @args;

    my $style = $args{style} // 0;
    my $fg = $coerceColor->( $args{fg} );
    my $bg = $coerceColor->( $args{bg} );

    assert ( looks_like_number $style );
    assert ( blessed $fg );
    assert ( blessed $bg );

    $v = ( $style & 0x3ff ) 
       | ( ( $fg & 0x7ffffff ) << 10 )
       | ( ( $bg & 0x7ffffff ) << 37 );
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
  return 0 unless $bios;
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

sub lshift {    # $result ($shift)
  my ( $self, $shift ) = @_;
  assert ( blessed $self );
  assert ( looks_like_number $shift );

  # Legacy code may use '<< 8' on an attribute to construct an attribute pair.
  if ( $shift == 8 ) {
    require TUI::Drivers::AttrPair;
    return TUI::Drivers::AttrPair->new(
      lo => TColorAttr->new( bios => 0 ), 
      hi => $self
    );
  }
  return $self->asBIOS << $shift;
}

use overload
  '0+' => \&asBIOS,
  '==' => \&equals,
  '<<' => \&lshift,
  fallback => 1;

sub getFore {    # $fg ()
  assert ( blessed $_[0] );
  my $color = ( ${ $_[0] } >> 10 ) & 0x7ffffff;
  return bless \$color, TColor;
}

sub getBack {    # $bg ()
  assert ( blessed $_[0] );
  my $color = ( ${ $_[0] } >> 37 ) & 0x7ffffff;
  return bless \$color, TColor;
}

sub getStyle {    # sytle ()
  assert ( blessed $_[0] );
  return ${ $_[0] } & 0x3ff;
}

sub setFore {    # void ($color)
  my ( $self, $color ) = @_;
  assert( blessed $self );
  assert( blessed $color or looks_like_number $color );
  ${$self} = ( ${$self} & ~( 0x7ffffff << 10 ) )
           | ( ( $color & 0x7ffffff ) << 10 );
  return;
}

sub setBack {    # void ($color)
  my ( $self, $color ) = @_;
  assert( blessed $self );
  assert( blessed $color or looks_like_number $color );
  ${$self} = ( ${$self} & ~( 0x7ffffff << 37 ) )
           | ( ( $color & 0x7ffffff ) << 37 );
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
    fg    => TColor->new( rgb => 0x892312 ),
    bg    => TColor->new( rgb => 0x7F00BB ),
    style => slBold | slItalic,
  );

The C<fg> and C<bg> arguments must be C<TColor> values.

=head3 Convenience syntax

As a shorthand, C<fg> and C<bg> also accept a hash reference or an array
reference instead of a C<TColor> object:

=over

=item C<[]> or C<{}>

The terminal default color.

=item C<< { ... } >>

Any hash reference is forwarded as-is to C<< TColor->new >>, e.g.
C<< { bios => 0xF } >>, C<< { rgb => 0x7F00BB } >> or C<< { xterm => 196 } >>.

=item C<< ['\x7'] >>, C<< ['\x07'] >>, C<< ['\x{07}'] >>

A BIOS color (0-15) from a hexadecimal escape. The bare form reads 1 or 2
hex digits; the braced form C<< \x{...} >> accepts any number of digits.

=item C<< ['\007'] >>, C<< ['\o{007}'] >>

A BIOS color (0-15) from an octal escape. The bare form reads 1 to 3 octal
digits; the braced form C<< \o{...} >> accepts any number of digits.

=item C<< ['0b0111'] >>

A BIOS color (0-15) from a 4-digit binary literal.

=item C<< [196] >>

An C<xterm-256color> palette index (0-255).

=item C<< ['#7fbb00'] >>

An RGB color in C<#RRGGBB> notation, one byte per channel.

=item C<< ['#7fb'] >>

The C<#RGB> shorthand of the above; each hex digit is doubled
(C<'#7fb'> is equivalent to C<'#77ffbb'>).

=item C<< [127, 0, 187] >>

An RGB color as a 3-element array of C<(r, g, b)> byte values.

=item C<< ["\x7"] >>

A single already-resolved byte, taken directly as a BIOS color via its
ordinal value. This is what a double-quoted escape like C<"\x7"> becomes
(see note below). Printable digits (C<'0'>..C<'9'>) are excluded, since
those are already handled above as C<xterm> indices.

=back

B<Note:> the escape forms (C<\xH>, C<\x{H..}>, C<\OOO>, C<\o{O..}>) are
plain text and are meant to be written with B<single quotes>, e.g.
C<['\x7']>. In double-quoted strings Perl resolves the escape itself
before C<new> ever sees it, turning C<"\x7"> into a single control
character instead of the 4-character text C<\x7>. Both spellings still
produce the same BIOS color 0x7, but only because of the single-byte
abbreviation above; for any other purpose the two are not interchangeable.

For example:

  my $attr = TColorAttr->new(
    fg => ['\x7'],
    bg => { rgb => 0x7F00BB },
  );

This is convenient for compact palette definitions.

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

=head2 lshift

 my $result = $self->lshift($shift);

Shifts the C<asBIOS> value left by C<$shift> bits.

As a special case, shifting by C<8> returns a new C<TAttrPair> whose high
attribute is this value and whose low attribute is a BIOS attribute of C<0>,
for compatibility with legacy code that used C<< << 8 >> on an attribute to
construct an attribute pair.

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

The argument must be a C<TColor> value.

=head2 setBack

  $self->setBack($color);

Sets the background color component.

The argument must be a C<TColor> value.

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

Returns true when C<TColorAttr> values contain identical data; support 
typecast to a BIOS value if one is a number.

=head2 Numeric conversion

  my $bios = 0+ $a;

Returns the BIOS color attribute equivalent to this value.

=head2 Left shift

  my $result = $a << $shift;

Calls L</lshift>.

=head1 SEE ALSO

L<TUI::Drivers::Const>,
L<TColor|TUI::Drivers::Color>,
L<TAttrPair|TUI::Drivers::AttrPair>,
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
