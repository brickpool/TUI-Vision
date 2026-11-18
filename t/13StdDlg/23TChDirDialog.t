use strict;
use warnings;

use Cwd ();
use File::Temp ();
use Test::More;
use Test::Exception;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Drivers::Event';
  use_ok 'TUI::Drivers::Const', qw( evCommand );
  use_ok 'TUI::Views::Group';
  use_ok 'TUI::StdDlg::Const', qw(
    cmRevert
    cmChangeDir
    cmDirSelection
  );
  use_ok 'TUI::Views::Const', qw( cmOK cmCancel );
  use_ok 'TUI::StdDlg::ChDirDialog';
  require_ok 'TUI::toolkit';
}

BEGIN {
  package MyOwner;
  use TUI::Views::Group;
  use TUI::toolkit;
  extends 'TUI::Views::Group';
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

subtest 'valid(cmOK) changes to the entered directory' => sub {
  my $orig = Cwd::getcwd();
  my $target = File::Temp::tempdir( CLEANUP => 1 );
  $dlg->{dirInput}{data} = $target;

  ok( $dlg->valid( cmOK ), 'valid(cmOK) accepts a valid directory' );
  is( Cwd::getcwd(), Cwd::abs_path( $target ), 'current directory changed' );

  chdir $orig;
};

subtest 'valid(cmCancel) does not change the directory' => sub {
  my $orig = Cwd::getcwd();
  my $target = File::Temp::tempdir( CLEANUP => 1 );
  $dlg->{dirInput}{data} = $target;

  ok( $dlg->valid( cmCancel ), 'valid(cmCancel) is accepted' );
  is( Cwd::getcwd(), $orig, 'current directory unchanged' );
};

subtest 'shutDown() survives' => sub {
  lives_ok { $dlg->shutDown() } 'shutDown() does not die';
};

done_testing;
