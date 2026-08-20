use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Drivers::Const', qw( :slXXXX );
  use_ok 'TUI::Drivers::Color';
  use_ok 'TUI::Drivers::ColorAttr';
  use_ok 'TUI::Drivers::AttrPair';
}

subtest 'default constructor' => sub {
  my $attr = TColorAttr->new();
  isa_ok( $attr, TColorAttr );

  isa_ok( $attr->getFore, TColor, 'foreground object' );
  isa_ok( $attr->getBack, TColor, 'background object' );

  is( $attr->getStyle, 0, 'default style' );
  ok( !$attr->isBIOS, 'default value is not BIOS compatible' );
};

subtest 'bios constructor' => sub {
  my $attr = TColorAttr->new( bios => 0x1f );
  isa_ok( $attr, TColorAttr );

  is( $attr->getStyle, 0, 'style bits are not set for BIOS attributes' );
  is( $attr->getFore->asBIOS, 0x0f, 'fg extracted' );
  is( $attr->getBack->asBIOS, 0x01, 'bg extracted' );

  ok( $attr->isBIOS, 'attribute is BIOS compatible' );
  is( $attr->asBIOS, 0x1f, 'roundtrip BIOS value' );
};

subtest 'explicit fg/bg/style constructor' => sub {
  my $attr = TColorAttr->new(
    fg    => TColor->new( rgb => 0xaaaaaa ),
    bg    => TColor->new( bios => 0x1 ),
    style => slBold
  );
  isa_ok( $attr, TColorAttr );

  is( $attr->getStyle, slBold, 'style bits are set' );
  ok( !$attr->isBIOS, 'attribute is not BIOS compatible' );
  is( $attr->toBIOS, 0x17, 'reconstructed BIOS value' );
};

subtest 'getters' => sub {
  my $fg   = TColor->new( rgb => 0xaaaaaa );
  my $bg   = TColor->new( rgb => 0x0000aa );
  my $attr = TColorAttr->new(
    fg    => $fg,
    bg    => $bg,
    style => slBlink,
  );

  ok( $attr->getFore == $fg, 'getFore' );
  ok( $attr->getBack == $bg, 'getBack' );
  is( $attr->getStyle, slBlink, 'getStyle' );
};

subtest 'setters' => sub {
  my $attr = TColorAttr->new();
  my $fg   = TColor->new( rgb => 0xaaaaaa );
  my $bg   = TColor->new( rgb => 0x0000aa );

  $attr->setFore( $fg );
  $attr->setBack( $bg );
  $attr->setStyle( slBlink );

  ok( $attr->getFore == $fg, 'setFore' );
  ok( $attr->getBack == $bg, 'setBack' );
  is( $attr->getStyle, slBlink, 'setStyle' );
};

subtest 'reverseAttribute swaps colors' => sub {
  my $fg   = TColor->new( bios => 1 );
  my $bg   = TColor->new( bios => 7 );
  my $attr = TColorAttr->new(
    fg => $fg,
    bg => $bg,
  );
  $attr->reverseAttribute;

  ok( $attr->getFore == $bg, 'foreground swapped' );
  ok( $attr->getBack == $fg, 'background swapped' );
};

subtest 'BIOS consistency validation' => sub {
  my $missing = TColorAttr->new(
    fg => TColor->new( rgb => 0xffffff ),
    bg => TColor->new( rgb => 0x0000aa ),
  );
  isa_ok( $missing, TColorAttr );

  ok( !$missing->isBIOS, 'attribute is not BIOS compatible' );
  is( $missing->toBIOS, 0x1f, 'reconstructed BIOS value' );

  my $compatible = TColorAttr->new(
    fg    => TColor->new( bios => 15 ),
    bg    => TColor->new( bios => 1 ),
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

subtest 'left shift' => sub {
  my $attr = TColorAttr->new( bios => 0x3d );

  is( $attr << 4, 0x3d << 4, 'shift by other amounts is numeric' );

  my $pair = $attr << 8;
  isa_ok( $pair, TAttrPair );
  ok( $pair->[1] == $attr, 'shift by 8 stores the attribute as hi' );
  ok( $pair->[0] == TColorAttr->new( bios => 0 ), 'shift by 8 defaults lo to zero' );
};

# Perl equivalents of the TColorAttr examples from magiblot's README
# (https://github.com/magiblot/tvision#extended-color-support)
subtest 'README parity: {} and [] abbreviations' => sub {

  # a1: fg RGB 0x892312, bg RGB 0x7F00BB, style Normal.
  my $a1 = TColorAttr->new(
    fg => [ 0x89, 0x23, 0x12 ],
    bg => [ 0x7f, 0x00, 0xbb ],
  );
  ok( $a1->getFore == TColor->new( rgb => 0x892312 ), 'a1 fg' );
  ok( $a1->getBack == TColor->new( rgb => 0x7f00bb ), 'a1 bg' );
  is( $a1->getStyle, 0, 'a1 style' );

  # a2: fg BIOS 0x7, bg RGB 0x7F00BB, style Bold|Italic.
  my $a2 = TColorAttr->new(
    fg    => [ '\x7' ],
    bg    => { rgb => 0x7f00bb },
    style => slBold | slItalic,
  );
  ok( $a2->getFore->isBIOS && $a2->getFore->asBIOS == 0x7, 'a2 fg' );
  ok( $a2->getBack == TColor->new( rgb => 0x7f00bb ), 'a2 bg' );
  is( $a2->getStyle, slBold | slItalic, 'a2 style' );

  # a3: fg terminal default, bg BIOS 0xF, style Normal.
  my $a3 = TColorAttr->new(
    fg => {},
    bg => [ '\xF' ],
  );
  ok( $a3->getFore->isDefault, 'a3 fg' );
  ok( $a3->getBack->isBIOS && $a3->getBack->asBIOS == 0xf, 'a3 bg' );
  is( $a3->getStyle, 0, 'a3 style' );

  # a4: fg terminal default, bg terminal default, style Normal.
  my $a4 = TColorAttr->new(
    fg => {},
    bg => {},
  );
  ok( $a4->getFore->isDefault, 'a4 fg' );
  ok( $a4->getBack->isDefault, 'a4 bg' );
  is( $a4->getStyle, 0, 'a4 style' );

  # a5: BIOS 0x70 (fg BIOS 0x0, bg BIOS 0x7).
  my $a5 = TColorAttr->new( bios => 0x70 );
  ok( $a5->getFore->isBIOS && $a5->getFore->asBIOS == 0x0, 'a5 fg' );
  ok( $a5->getBack->isBIOS && $a5->getBack->asBIOS == 0x7, 'a5 bg' );
  is( $a5->asBIOS, 0x70, 'a5 roundtrip' );
};

subtest '7 vs. \'7\' vs. \'\x7\' vs. "\x7"' => sub {

  # 7 and '7': a bare number and a numeric string are indistinguishable
  # to looks_like_number, so both are read as an xterm palette index.
  my $attr = TColorAttr->new( fg => [7], bg => [0] );
  ok( $attr->getFore->isXTerm, "[7] is xterm" );
  is( $attr->getFore->asXTerm, 7, "[7] xterm index 7" );
  ok( !$attr->getFore->isBIOS, "[7] is not BIOS" );

  $attr = TColorAttr->new( fg => ['7'], bg => [0] );
  ok( $attr->getFore->isXTerm, "['7'] is xterm" );
  is( $attr->getFore->asXTerm, 7, "['7'] xterm index 7" );
  ok( !$attr->getFore->isBIOS, "['7'] is not BIOS" );

  # '\x7' (single-quoted): the literal 4-character text is matched by
  # the hex-escape abbreviation.
  my $quoted = TColorAttr->new( fg => ['\x7'], bg => [0] );
  ok( $quoted->getFore->isBIOS, q{['\x7'] is BIOS} );
  is( $quoted->getFore->asBIOS, 0x7, q{['\x7'] BIOS value 0x7} );

  # "\x7" (double-quoted): Perl already resolved this into the single
  # byte chr(7) before new saw it. It ends up as BIOS 0x7 too,
  # but only via the single-byte-ordinal fallback, not the escape regex.
  my $resolved = TColorAttr->new( fg => ["\x7"], bg => [0] );
  ok( $resolved->getFore->isBIOS, q{["\x7"] is BIOS} );
  is( $resolved->getFore->asBIOS, 0x7, q{["\x7"] BIOS value 0x7} );

  # Both spellings of \x7 happen to produce the same numeric BIOS value.
  ok(
    $quoted->getFore == $resolved->getFore,
    q{['\x7'] and ["\x7"] produce the same color}
  );
};

done_testing();
