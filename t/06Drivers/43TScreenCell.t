use strict;
use warnings;

use Test::More;
use Scalar::Util qw( refaddr );

BEGIN {
  use_ok 'TUI::Drivers::ColorAttr';
  use_ok 'TUI::Drivers::CellChar';
  use_ok 'TUI::Drivers::ScreenCell';
}

subtest 'default constructor' => sub {
  my $cell = TScreenCell->new();
  isa_ok( $cell, TScreenCell );

  isa_ok( $cell->getAttr, TColorAttr );
  isa_ok( $cell->getChar, TCellChar );

  ok( !$cell->isWide, 'default cell is not wide' );
};

subtest 'bios constructor' => sub {
  my $cell = TScreenCell->new( bios => ( 0x1F << 8 ) | ord('A') );
  isa_ok( $cell, TScreenCell );

  isa_ok( $cell->getAttr, TColorAttr );
  isa_ok( $cell->getChar, TCellChar );

  ok( $cell->getAttr->isBIOS, 'BIOS attribute preserved' );

  is( $cell->getAttr->asBIOS, 0x1F, 'roundtrip BIOS attribute' );
};

subtest 'setChar with string' => sub {
  my $cell = TScreenCell->new();

  $cell->setChar( 'A' );
  isa_ok( $cell->getChar, TCellChar );
  is( $cell->getChar->getText, 'A', 'character stored' );
};

subtest 'setChar with TCellChar' => sub {
  my $char = TCellChar->new(
    text => "\x{754C}",    # 界
  );
  my $cell = TScreenCell->new();
  $cell->setChar( $char );

  ok( refaddr( $cell->getChar ) != refaddr( $char ), 'character copied by value' );
  is( $cell->getChar->getText, $char->getText, 'character value preserved' );
  ok( $cell->isWide, 'wide character detected' );
};

subtest 'setAttr' => sub {
  my $attr = TColorAttr->new( bios => 0x1F );
  my $cell = TScreenCell->new();
  $cell->setAttr( $attr );

  ok( refaddr( $cell->getAttr ) != refaddr( $attr ), 'attribute copied by value' );
  is( $cell->getAttr->asBIOS, $attr->asBIOS, 'attribute value preserved' );

  $cell->setAttr(0x2E);
  is( $cell->getAttr->asBIOS, 0x2E, 'numeric BIOS attribute preserved' );
};

subtest 'setCell' => sub {
  my $attr = TColorAttr->new( bios => 0x1F );
  my $cell = TScreenCell->new();

  $cell->setCell( 'A', $attr );
  is( $cell->getChar->getText, 'A', 'character stored');
  ok( refaddr( $cell->getAttr ) != refaddr( $attr ), 'attribute copied by value' );
  is( $cell->getAttr->asBIOS, $attr->asBIOS, 'attribute value stored' );
};

subtest 'equals' => sub {
  my $a = TScreenCell->new( bios => 0x1F );
  my $b = TScreenCell->new( bios => 0x1F );

  ok( $a == $b, 'equal cells compare equal' );

  $b->setChar( 'A' );
  ok( !( $a == $b ), 'modified cell differs' );
};

subtest 'wide character trail' => sub {
  my $cell = TScreenCell->new();
  $cell->setChar( TCellChar->new( text => "\0" ) );

  ok( $cell->getChar->isWideCharTrail, 'trail placeholder detected' );
};

done_testing();
