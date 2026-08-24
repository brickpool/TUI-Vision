use strict;
use warnings;
use utf8;

use Test::More;

BEGIN {
  use_ok 'TUI::Drivers::CellChar';
}

subtest 'default constructor' => sub {
  my $ch = TCellChar->new();
  isa_ok( $ch, TCellChar );

  is( length( $$ch ), 0,    'length of default text is zero' );
  is( $ch->getText,   "\0", 'default text' );
  is( $ch->size,      1,    'default size' );

  ok( !$ch->isWide, 'default cell is not wide' );
};

subtest 'text constructor' => sub {
  my $ch = TCellChar->new( text => 'A' );
  isa_ok( $ch, TCellChar );

  is( $ch->getText, 'A', 'stored text' );
  is( $ch->size,    1,   'size in bytes' );
  ok( !$ch->isWide, 'ASCII character is not wide' );
  ok( !$ch->isWideCharTrail, 'ASCII character is not a trail' );
};

subtest 'wide char trail' => sub {
  my $trail = TCellChar->new( text => "\0" );
  isa_ok( $trail, TCellChar );

  ok( $trail->isWideCharTrail, 'trail placeholder detected');
};

subtest 'invalid constructor' => sub {
  ok(
    !defined( TCellChar->new( txt => 'A' ) ),
    'unknown constructor argument'
  );
};

subtest 'byte length semantics' => sub {
  my $ascii = TCellChar->new( text => 'A' );
  isa_ok( $ascii, TCellChar );
  is( $ascii->size, 1, 'ASCII occupies one byte' );

  my $nul = TCellChar->new( text => "\0" );
  isa_ok( $nul, TCellChar );
  is( $nul->size, 1, 'trail marker occupies one byte' );
};

subtest 'wide character detection' => sub {
  my $ascii = TCellChar->new( text => 'A' );
  isa_ok( $ascii, TCellChar );
  ok( !$ascii->isWide, 'ASCII character is not wide' );

  my $wide = TCellChar->new(
    text => "\x{754C}",    # 界
  );
  isa_ok( $wide, TCellChar );
  ok( $wide->isWide, 'wide character detected' );
  ok( !$wide->isWideCharTrail, 'wide character is not a trail' );

  my $egc = TCellChar->new( text => "e\x{301}" );
  isa_ok( $egc, TCellChar );
  is( $egc->size, 3, 'UTF-8 byte length' );
  ok( !$egc->isWide, 'EGC occupies one screen column' );

  my $emoji = TCellChar->new(
    text => "\x{1F600}",    # 😀
  );
  isa_ok( $emoji, TCellChar );
  ok( $emoji->isWide, 'emoji is wide' );
};

subtest 'UTF-8 byte length semantics' => sub {
  my $wide = TCellChar->new( text => "\x{754C}" );
  isa_ok( $wide, TCellChar );
  is( $wide->size, 3, 'CJK character occupies three UTF-8 bytes' );
};

subtest 'mutation methods' => sub {
  my $ch = TCellChar->new();
  isa_ok( $ch, TCellChar );

  $ch->moveChar( 'A' );
  is( $ch->getText, 'A', 'moveChar' );
  is( $ch->size,    1,   'moveChar size' );
  ok( !$ch->isWide, 'moveChar is not wide' );

  $ch->moveMultiByteChar( "\x{754C}" );    # 界
  is( $ch->getText, "\x{754C}", 'moveMultiByteChar' );
  ok( $ch->isWide, 'moveMultiByteChar is wide' );

  $ch->moveWideCharTrail();
  ok( $ch->isWideCharTrail, 'moveWideCharTrail' );
  is( $ch->getText, "\0", 'trail marker text' );

  my $cell = TCellChar->new( text => 'A' );
  is( $cell->getText, 'A', 'getText returns the stored character' );

  $cell->moveChar('0');
  is( $cell->getText, '0', "getText preserves literal '0'" );
};

subtest 'appendZeroWidthChar' => sub {
  my $ch = TCellChar->new( text => 'e' );

  $ch->appendZeroWidthChar(
    "\x{301}",    # COMBINING ACUTE ACCENT
  );

  is( $ch->getText, "e\x{301}", 'zero-width character appended' );
  ok( !$ch->isWide, 'resulting EGC occupies one column' );
  is( $ch->size, 3, 'UTF-8 byte length preserved' );
};

done_testing();
