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

use TUI::Drivers::Const qw( :slXXXX );

sub TColorAttr() { __PACKAGE__ }

sub new {    # $attr (|%args)
  my ( $class, @args ) = @_;

  # TColorAttr->new()
  return bless( \( my $v = 0 ), $class )
    unless @args;

  # TColorAttr->new( bios => Int )
  if ( @args == 2 && $args[0] eq 'bios' ) {
    my $bios = 0+ $args[1];
    
    my $fg = $bios          & 0x0f;
    my $bg = ( $bios >> 4 ) & 0x0f;
    
    my $style = 0;
    $style |= slBold if $fg  & 0x08;
    $style |= slBlink if $bg & 0x08;

    my $v = ( $style & 0x3ff )
          | ( ( $fg & 0x7ffffff ) << 10 )
          | ( ( $bg & 0x7ffffff ) << 37 );

    return bless \$v, $class;
  }

  # TColorAttr->new(
  #   fg    => Int,
  #   bg    => Int,
  #   | style => Int
  # )
  return 
    unless @args % 2 == 0;
  my %args = @args;
  if ( exists $args{fg} && exists $args{bg} ) {
    my $fg    = 0+ $args{fg};
    my $bg    = 0+ $args{bg};
    my $style = 0+ ( $args{style} || 0 );

    my $v = ( $style & 0x3ff ) 
          | ( ( $fg & 0x7ffffff ) << 10 )
          | ( ( $bg & 0x7ffffff ) << 37 );

    return bless \$v, $class;
  }

  return;
} #/ sub new

sub getStyle {    # sytle ()
  return ${ $_[0] } & 0x3ff;
}

sub getFore {    # $fg ()
  return ( ${ $_[0] } >> 10 ) & 0x7ffffff;
}

sub getBack {    # $bg ()
  return ( ${ $_[0] } >> 37 ) & 0x7ffffff;
}

sub isBIOS {    # $bool ()
  my ( $self ) = @_;

  my $style = ${$self} & 0x3ff;
  my $fg    = ( ${$self} >> 10 ) & 0x7ffffff;
  my $bg    = ( ${$self} >> 37 ) & 0x7ffffff;

return $fg <= 0x0f && $bg <= 0x0f
    && ( $style & ~( slBold | slBlink ) ) == 0
    && ( ( $style & slBold  ) xor !( $fg & 0x08 ) )
    && ( ( $style & slBlink ) xor !( $bg & 0x08 ) );
}

sub asBIOS {    # $attr ()
  my ( $self ) = @_;

  # $$self must be a BIOS attribute. If it is not, the result will be
  # bogus but harmless. The important is that the result isn't '\x0'
  # unless this is BIOS attribute '\x0'.
  my $fg = ( ${$self} >> 10 ) & 0x0f;
  my $bg = ( ${$self} >> 37 ) & 0x0f;

  my $bios = $fg | ( $bg << 4 );
  return $self->isBIOS ? $bios : 0x5F;
}

sub toBIOS {    # $attr ()
  my ( $self ) = @_;

  return $self->asBIOS
    if $self->isBIOS;

  my $fg = ( ${$self} >> 10 ) & 0x7ffffff;
  my $bg = ( ${$self} >> 37 ) & 0x7ffffff;

  # TODO: RGB -> BIOS or XTerm256 -> BIOS quantization is not yet implemented. 
  # This is a non-trivial task, as it requires mapping the RGB/Xterm color 
  # space to the limited BIOS color palette. 
  #
  # A possible approach could involve calculating the closest match in the 
  # BIOS palette for the given RGB values, but this would require additional 
  # logic and possibly a predefined mapping to BIOS colors.
  my $bios_fg = 0;
  my $bios_bg = 0;
  ...;

  return ( $bios_bg << 4 ) | $bios_fg;
}

1;

__END__

=head1 NAME

TUI::Drivers::ColorAttr - color attribute value type for screen cells

=head1 SYNOPSIS

  use TUI::Drivers::ColorAttr;

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

=head2 toBIOS

 my $attr = $self->toBIOS();

Returns a BIOS color attribute for this value.

=head1 SEE ALSO

L<TUI::Drivers::Const>,
L<TScreenCell|TUI::Drivers::ScreenCell>,
L<TCellChar|TUI::Drivers::CellChar>

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
