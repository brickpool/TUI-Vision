use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
  use_ok 'TV::Objects::Rect';
  use_ok 'TV::Drivers::Event';
  use_ok 'TV::Drivers::Const', qw( evCommand );
  use_ok 'TV::Views::Group';
  use_ok 'TV::StdDlg::Const', qw(
    cmRevert
    cmChangeDir
    cmDirSelection
  );
  use_ok 'TV::StdDlg::ChDirDialog';
  require_ok 'TV::toolkit';
}

BEGIN {
  package MyOwner;
  use TV::Views::Group;
  use TV::toolkit;
  extends 'TV::Views::Group';
  has directory => ( is => 'rw' );
  $INC{"MyOwner.pm"} = 1;
}

use_ok 'MyOwner';

my $dlg;
my $owner;

subtest 'Object creation' => sub {
  lives_ok {
    $dlg = TChDirDialog->new(
      options => 0,
      histId  => 1,
    );
  } 'TChDirDialog object created';

  isa_ok( $dlg, TChDirDialog() );

  my $bounds = TRect->new( ax => 0, ay => 0, bx => 80, by => 20 );
  $owner = MyOwner->new( bounds => $bounds );
  $owner->directory( 'C:\\' );

  $dlg->owner( $owner );
};

subtest 'handleEvent() cmRevert survives' => sub {
  my $event = TEvent->new(
    what    => evCommand,
    command => cmRevert,
  );
  lives_ok { $dlg->handleEvent( $event ) } 'handleEvent(cmRevert) lives';
};

subtest 'handleEvent() cmChangeDir survives' => sub {
  my $event = TEvent->new(
    what    => evCommand,
    command => cmChangeDir,
  );
  lives_ok { $dlg->handleEvent( $event ) } 'handleEvent(cmChangeDir) lives';
};

subtest 'handleEvent() cmDirSelection survives' => sub {
  my $event = TEvent->new(
    what    => evCommand,
    command => cmDirSelection,
    infoPtr => 1,
  );
  lives_ok { $dlg->handleEvent( $event ) } 'handleEvent(cmDirSelection) lives';
};

subtest 'valid() survives' => sub {
  lives_ok { $dlg->valid( 0 ) } 'valid() does not die';
};

subtest 'shutDown() survives' => sub {
  lives_ok { $dlg->shutDown() } 'shutDown() does not die';
};

done_testing;
