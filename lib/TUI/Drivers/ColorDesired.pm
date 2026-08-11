package TUI::Drivers::ColorDesired;
# ABSTRACT: union type representing a desired foreground or background color

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TColorDesired
);

use PerlX::Assert::PP;
use Scalar::Util qw(
  blessed
  looks_like_number
);

use TUI::Drivers::Const qw( :ctXXXX );
use TUI::Drivers::Colors qw(
  RGBtoBIOS
  XTerm256toXTerm16
  XTerm16toBIOS
);

sub TColorDesired() { __PACKAGE__ }

sub new {    # $cell (|%args)
  my ( $class, @args ) = @_;
  assert ( $class and !ref $class );

  # TColorDesired->new()
  my $bits;
  if (!@args) {
    $bits = 0;
  }

  # TColorDesired->new( bios => Int )
  elsif ( @args == 2 && $args[0] eq 'bios' ) {
    my $bios = $args[1];
    assert ( looks_like_number $bios );
    $bits = ( $bios & 0x0f ) 
          | ( ctBIOS << 24 );
  }

  # TColorDesired->new( rgb => Int | ArrayRef )
  elsif ( @args == 2 && $args[0] eq 'rgb' ) {
    my $rgb = $args[1];
    if ( ref $rgb eq 'ARRAY' ) {
      assert ( @$rgb == 3 );
      $rgb = unpack 'V', pack 'C4', ( @$rgb, 0 )
    }
    assert ( looks_like_number $rgb );
    $bits = ( $rgb & 0x00ffffff )
          | ( ctRGB << 24 );
  }

  # TColorDesired->new( xterm => Int )
  elsif ( @args == 2 && $args[0] eq 'xterm' ) {
    my $xterm = $args[1];
    assert ( looks_like_number $xterm );
    $bits = ( $xterm & 0xff )
          | ( ctXTerm << 24 );
  }

  else {
    return;
  }

  return bless \$bits, $class;
}

sub type {   # $type ()
  assert ( blessed $_[0] );
  return ${ $_[0] } >> 24;
}

sub isDefault {    # $bool ()
  assert ( blessed $_[0] );
  return $_[0]->type == ctDefault;
}

sub isBIOS {    # $bool ()
  assert ( blessed $_[0] );
  return $_[0]->type == ctBIOS;
}

sub isRGB {    # $bool ()
  assert ( blessed $_[0] );
  return $_[0]->type == ctRGB;
}

sub isXTerm {    # $bool ()
  assert ( blessed $_[0] );
  return $_[0]->type == ctXTerm;
}

sub asBIOS {    # $bios ()
  assert ( blessed $_[0] );
  return ${ $_[0] };
}

sub asRGB {    # $rgb ()
  assert ( blessed $_[0] );
  return ${ $_[0] };
}

sub asXTerm {    # $xterm ()
  assert ( blessed $_[0] );
  return ${ $_[0] };
}

# Quantization to TColorBIOS.
sub toBIOS {    # $bios ($isForeground)
  my ( $self, $isForeground ) = @_;
  assert ( blessed $self );

  switch: for ( $self->type ) {
    case: ctBIOS == $_ and 
      return $self->asBIOS();
    case: ctRGB == $_ and
      return RGBtoBIOS( $self->asRGB() );
    case: ctXTerm == $_ and do {
      my $idx = $self->asXTerm();
      $idx = XTerm256toXTerm16( $idx )
        if $idx >= 16;
      return XTerm16toBIOS( $idx );
    };
    default: {
      return $isForeground ? 0x7 : 0x0;
    }
  }
}

sub equals {    # $bool ($other)
  my ( $self, $other ) = @_;
  assert ( blessed $self );
  assert ( blessed $other );
  return $$self == $$other;
}

use overload
  '==' => \&equals,
  fallback => 1;

sub bitCast {    # $bits|undef (|$bits)
  assert ( blessed $_[0] );
  if ( @_ > 1 ) {
    assert ( looks_like_number $_[1] );
    ${ $_[0] } = $_[1] & 0xffffffff;
    return;
  }
  return ${ $_[0] };
}

1;

__END__

=head1 NAME

TColorDesired - union type representing a desired foreground or background color

=head1 SYNOPSIS

  use TUI::Drivers;

  my $default = TColorDesired->new();

  my $bios = TColorDesired->new(
    bios => 0xF,
  );

  my $rgb = TColorDesired->new(
    rgb => 0x7F00BB,
  );

  my $xterm = TColorDesired->new(
    xterm => 196,
  );

  if ( $rgb->isRGB ) {
    my $value = $rgb->asRGB;
  }

  my $biosColor = $rgb->toBIOS(1);

=head1 DESCRIPTION

C<TUI::Drivers::ColorDesired> provides C<TColorDesired>, a value type that
represents one desired color.

A C<TColorDesired> may represent one of several color kinds:

=over

=item *

Terminal default color

=item *

BIOS color values

=item *

XTerm color values

=item *

24-bit RGB colors

=back

The purpose of this type is to describe either the foreground or background
color of a screen cell.

In a terminal emulator, the default color represents text displayed without
any explicit color attributes.

=head1 CONSTRUCTOR

=head2 new

Creates a desired color value.

With no arguments, a default terminal color is created:

  my $color = TColorDesired->new();

Create a BIOS color:

  my $color = TColorDesired->new(
    bios => 0xF,
  );

Create an RGB color:

  my $color = TColorDesired->new(
    rgb => 0x7F00BB,
  );

An RGB color may also be specified as an RGB triplet:

  my $color = TColorDesired->new(
    rgb => [ 127, 0, 187 ],
  );

Create an XTerm color:

  my $color = TColorDesired->new(
    xterm => 196,
  );

=head1 METHODS

=head2 asBIOS

  my $bios = $self->asBIOS();

Returns the stored value as a BIOS color.

No conversion is performed. Make sure to verify the color type first.

=head2 asRGB

  my $rgb = $self->asRGB();

Returns the stored value as an RGB color.

No conversion is performed. Make sure to verify the color type first.

=head2 asXTerm

  my $xterm = $self->asXTerm();

Returns the stored value as an XTerm color.

No conversion is performed. Make sure to verify the color type first.

=head2 bitCast

  my $bits = $self->bitCast();
  $self->bitCast( $bits );

Returns or replaces the underlying integer representation.

No conversion is performed.

=head2 equals

  my $bool = $self->equals(
    $other,
  );

Returns true if both values represent exactly the same color value and type.

=head2 isDefault

  my $bool = $self->isDefault();

Returns true if the value represents the terminal default color.

=head2 isBIOS

  my $bool = $self->isBIOS();

Returns true if the value represents a BIOS color.

=head2 isRGB

  my $bool = $self->isRGB();

Returns true if the value represents a 24-bit RGB color.

=head2 isXTerm

  my $bool = $self->isXTerm();

Returns true if the value represents an XTerm color.

=head2 toBIOS

  my $bios = $self->toBIOS(
    $isForeground,
  );

Returns a BIOS color equivalent to the current value.

RGB and XTerm colors are quantized to the nearest BIOS-compatible color.

When the value represents the terminal default color, the returned value is
the standard foreground or background BIOS color depending on the value of
C<$isForeground>.

=head2 type

  my $type = $self->type();

Returns the color type.

The return value is one of, exported by L<TUI::Drivers::Const>:

  ctDefault
  ctBIOS
  ctRGB
  ctXTerm

=head1 OPERATORS

=head2 Numeric equality

  $a == $b

Returns true when two C<TColorDesired> values contain identical data.

=head1 SEE ALSO

L<TUI::Drivers::Const>,
L<TColorAttr|TUI::Drivers::ColorAttr>,
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
