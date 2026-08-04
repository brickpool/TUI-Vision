use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Drivers::Const', qw( :slXXXX );
  use_ok 'TUI::Drivers::ColorAttr';
}

subtest 'default constructor' => sub {
  my $attr = TColorAttr->new();

  isa_ok( $attr, TColorAttr );

  is( $attr->getStyle, 0, 'default style' );
  is( $attr->getFore,  0, 'default foreground' );
  is( $attr->getBack,  0, 'default background' );

  ok( $attr->isBIOS, 'default value is BIOS compatible' );

  done_testing();
};

subtest 'bios constructor' => sub {
  my $attr = TColorAttr->new(
    bios => 0x1F,
  );

  is( $attr->getFore, 0x0F, 'fg extracted' );
  is( $attr->getBack, 0x01, 'bg extracted' );

  ok(
    $attr->getStyle & slBold,
    'slBold inferred from BIOS attribute'
  );

  ok(
    $attr->isBIOS,
    'attribute is BIOS compatible'
  );

  is(
    $attr->asBIOS, 0x1F,
    'roundtrip BIOS value'
  );

  done_testing();
}; #/ 'bios constructor' => sub

subtest 'explicit fg/bg/style constructor' => sub {
  my $attr = TColorAttr->new(
    fg    => 0x0F,
    bg    => 0x01,
    style => slBold,
  );

  ok(
    $attr->isBIOS,
    'consistent BIOS attribute'
  );

  is(
    $attr->asBIOS, 0x1F,
    'reconstructed BIOS value'
  );

  done_testing();
}; #/ 'explicit fg/bg/style constructor' => sub

subtest 'BIOS consistency validation' => sub {
  my $missing_bold = TColorAttr->new(
    fg    => 0x0F,
    bg    => 0x01,
    style => 0,
  );

  ok(
    !$missing_bold->isBIOS,
    'high intensity fg requires slBold'
  );

  my $extra_bold = TColorAttr->new(
    fg    => 0x07,
    bg    => 0x01,
    style => slBold,
  );

  ok(
    !$extra_bold->isBIOS,
    'slBold without intensity bit is invalid'
  );

  done_testing();
}; #/ 'BIOS consistency validation' => sub

subtest 'all BIOS values roundtrip' => sub {
  for my $bios ( 0 .. 255 ) {
    my $attr = TColorAttr->new(
      bios => $bios,
    );

    my $name = sprintf( '0x%02x', $bios );
    ok( $attr->isBIOS, "$name is BIOS compatible" );
    is( $attr->asBIOS, $bios, "$name roundtrip" );
  }
};

done_testing();
