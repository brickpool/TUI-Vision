use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Drivers::Const', qw( :slXXXX );
  use_ok 'TUI::Drivers::ColorDesired';
  use_ok 'TUI::Drivers::ColorAttr';
}

subtest 'default constructor' => sub {
  my $attr = TColorAttr->new();
  isa_ok( $attr, TColorAttr );

  isa_ok( $attr->getFore, TColorDesired, 'foreground object' );
  isa_ok( $attr->getBack, TColorDesired, 'background object' );

  is( $attr->getStyle, 0, 'default style' );
  ok( !$attr->isBIOS, 'default value is not BIOS compatible' );
};

subtest 'bios constructor' => sub {
  my $attr = TColorAttr->new( bios => 0x1f );
  isa_ok( $attr, TColorAttr );

  is( $attr->getStyle, 0, 'style bits are not set for BIOS attributes' );
  is( $attr->getFore->bitCast & 0xffffff, 0x0f, 'fg extracted' );
  is( $attr->getBack->bitCast & 0xffffff, 0x01, 'bg extracted' );

  ok( $attr->isBIOS, 'attribute is BIOS compatible' );
  is( $attr->asBIOS, 0x1f, 'roundtrip BIOS value' );
};

subtest 'explicit fg/bg/style constructor' => sub {
  my $attr = TColorAttr->new(
    fg    => TColorDesired->new( rgb => 0xaaaaaa ),
    bg    => TColorDesired->new( bios => 0x1 ),
    style => slBold
  );
  isa_ok( $attr, TColorAttr );

  is( $attr->getStyle, slBold, 'style bits are set' );
  ok( !$attr->isBIOS, 'attribute is not BIOS compatible' );
  is( $attr->toBIOS, 0x17, 'reconstructed BIOS value' );
};

subtest 'getters' => sub {
  my $fg   = TColorDesired->new( rgb => 0xaaaaaa );
  my $bg   = TColorDesired->new( rgb => 0x0000aa );
  my $attr = TColorAttr->new(
    fg    => $fg,
    bg    => $bg,
    style => slBlink,
  );

  is( $attr->getFore->bitCast, $fg->bitCast, 'getFore' );
  is( $attr->getBack->bitCast, $bg->bitCast, 'getBack' );
  is( $attr->getStyle,         slBlink,      'getStyle' );
};

subtest 'setters' => sub {
  my $attr = TColorAttr->new();
  my $fg   = TColorDesired->new( rgb => 0xaaaaaa );
  my $bg   = TColorDesired->new( rgb => 0x0000aa );

  $attr->setFore( $fg );
  $attr->setBack( $bg );
  $attr->setStyle( slBlink );

  is( $attr->getFore->bitCast, $fg->bitCast, 'setFore' );
  is( $attr->getBack->bitCast, $bg->bitCast, 'setBack' );
  is( $attr->getStyle,         slBlink,      'setStyle' );
};

subtest 'reverseAttribute swaps colors' => sub {
  my $fg   = TColorDesired->new( bios => 1 );
  my $bg   = TColorDesired->new( bios => 7 );
  my $attr = TColorAttr->new(
    fg => $fg,
    bg => $bg,
  );
  $attr->reverseAttribute;

  is( $attr->getFore->bitCast, $bg->bitCast, 'foreground swapped' );
  is( $attr->getBack->bitCast, $fg->bitCast, 'background swapped' );
};

subtest 'BIOS consistency validation' => sub {
  my $missing = TColorAttr->new(
    fg => TColorDesired->new( rgb => 0xffffff ),
    bg => TColorDesired->new( rgb => 0x0000aa ),
  );
  isa_ok( $missing, TColorAttr );

  ok( !$missing->isBIOS, 'attribute is not BIOS compatible' );
  is( $missing->toBIOS, 0x1f, 'reconstructed BIOS value' );

  my $compatible = TColorAttr->new(
    fg    => TColorDesired->new( bios => 15 ),
    bg    => TColorDesired->new( bios => 1 ),
    style => 0,
  );
  isa_ok( $compatible, TColorAttr );

  ok( $compatible->isBIOS, 'attribute is BIOS compatible' );
  is( $compatible->asBIOS, 0x1f, 'roundtrip BIOS value' );
};

subtest 'all BIOS values roundtrip' => sub {
  for my $bios ( 0 .. 255 ) {
    my $attr = TColorAttr->new( bios => $bios );
    my $name = sprintf( '0x%02x', $bios );
    ok( $attr->isBIOS, "$name is BIOS compatible" );
    is( $attr->asBIOS, $bios, "$name roundtrip" );
  }
};

subtest 'numeric overload' => sub {
  my $attr = TColorAttr->new( bios => 0x3d );
  isa_ok( $attr, TColorAttr );

  is( 0+ $attr, 0x3d, '0+ overload returns BIOS value' );
  ok( $attr == 0x3d, 'numeric comparison works' );
};

done_testing();
