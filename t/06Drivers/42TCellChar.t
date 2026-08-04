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

  is( $ch->getText, "\0", 'default text' );
  is( $ch->size,    1,    'default size' );
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

done_testing();
