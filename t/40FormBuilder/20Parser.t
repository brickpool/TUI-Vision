use strict;
use warnings;

use Test::More;
use TUI::FormBuilder::Parser;

my $parser = TUI::FormBuilder::Parser->new;

subtest 'source before and after the form' => sub {
  my $before = <<'BASIC';
' Form module declarations
DIM SharedValue AS INTEGER

BASIC
  my $after = <<'BASIC';


SUB Button1_Click ()
    PRINT "Clicked"
END SUB
BASIC
  my $form = <<'FRM';
Version 1.00
BEGIN Form Form1
    BEGIN CommandButton Button1
        Caption = "OK"
    END
END
FRM
  chomp $form;

  my $ast = $parser->from_string( $before . $form . $after );

  is( $ast->{source_before}, $before, 'preserves source before Version' );
  is( $ast->{source_after}, $after, 'preserves source after the form END' );
  is( $ast->{form}{children}[0]{name}, 'Button1',
    'parses the nested control between the source regions' );
};

subtest 'documented form, timer, label and menu properties' => sub {
  my $ast = $parser->from_string( <<'FRM' );
Version 1.00
BEGIN Form frmClock
    ControlBox = -1
    ForeColor = QBColor(0)
    MaxButton = 0
    MinButton = -1
    MousePointer = 0
    WindowState = 0
    BEGIN Label lblTime
        AutoSize = 0
        DragMode = 0
    END
    BEGIN Timer tmrClockTick
        Interval = 1000
    END
    BEGIN Menu mnuSettings
        Separator = 0
        BEGIN Menu mnuOption
            Separator = -1
            Shortcut = {F2}
        END
    END
END
FRM

  is_deeply(
    $ast->{form}{properties},
    {
      ControlBox => -1, ForeColor => 'QBColor(0)', MaxButton => 0,
      MinButton => -1, MousePointer => 0, WindowState => 0,
    },
    'parses the additional form properties',
  );
  my ( $label, $timer, $menu ) = @{ $ast->{form}{children} };
  is_deeply( $label->{properties}, { AutoSize => 0, DragMode => 0 },
    'parses label properties' );
  is( $timer->{properties}{Interval}, 1000, 'parses timer interval' );
  is_deeply(
    $menu->{children}[0]{properties},
    { Separator => -1, Shortcut => '{F2}' },
    'parses a nested menu separator and shortcut',
  );
};

subtest 'documented controls and their properties' => sub {
  my $ast = $parser->from_string( <<'FRM' );
Version 1.00
BEGIN MDIForm frmMain
    BEGIN Frame Frame1
        BEGIN DirListBox Dir1
            Path = "TEMP"
            ListCount = 0
            ListIndex = -1
        END
        BEGIN Custom VSpin
            Action = 0
            TypeID = "Spin"
        END
        BEGIN HScrollBar hscHelp
            Attached = -1
            LargeChange = 20
            Max = 32767
            Min = 1
            SmallChange = 1
        END
    END
    BEGIN FileListBox File1
        Archive = -1
        Hidden = 0
        Normal = -1
        Pattern = "*.*"
        ReadOnly = -1
        System = 0
    END
    BEGIN TextBox Text1
        MultiLine = 0
        ScrollBars = 0
        TabStop = -1
        Text = ""
    END
END
FRM

  is( $ast->{form}{type}, 'MDIForm', 'retains the MDI form type' );
  my ( $frame, $file, $text ) = @{ $ast->{form}{children} };
  my ( $dir, $custom, $scroll ) = @{ $frame->{children} };
  is( $dir->{type}, 'DirListBox', 'parses a nested directory list' );
  is_deeply( $dir->{properties},
    { Path => 'TEMP', ListCount => 0, ListIndex => -1 },
    'parses documented directory list properties' );
  is_deeply( [ $custom->{type}, $custom->{properties} ],
    [ 'Custom', { Action => 0, TypeID => 'Spin' } ],
    'parses an observed custom control' );
  is_deeply( $scroll->{properties},
    { Attached => -1, LargeChange => 20, Max => 32767, Min => 1,
      SmallChange => 1 },
    'parses scroll bar properties' );
  is_deeply( $file->{properties},
    { Archive => -1, Hidden => 0, Normal => -1, Pattern => '*.*',
      ReadOnly => -1, System => 0 },
    'parses file filters' );
  is_deeply( $text->{properties},
    { MultiLine => 0, ScrollBars => 0, TabStop => -1, Text => '' },
    'parses text box properties' );
};

subtest 'FRM string values' => sub {
  my $ast = $parser->from_string( <<'FRM' );
Version 1.00
BEGIN Form Form1
    Caption = "Last""2"""
    Tag = "C:\TEMP\FILE.TXT"
    Text = ""
    BEGIN TextBox Text1
        Text = "A\nB"
    END
END
FRM

  is( $ast->{form}{properties}{Caption}, 'Last"2"',
    'decodes doubled quotes without retaining delimiters' );
  is( $ast->{form}{properties}{Tag}, 'C:\TEMP\FILE.TXT',
    'preserves backslashes in a path' );
  is( $ast->{form}{properties}{Text}, '', 'parses an empty string' );
  is( $ast->{form}{children}[0]{properties}{Text}, 'A\nB',
    'does not interpret backslash escapes' );
};

subtest 'menu shortcuts with Control modifier' => sub {
  my $ast = $parser->from_string( <<'FRM' );
Version 1.00
BEGIN MDIForm frmBooklook
    BEGIN Menu mnuFile
        BEGIN Menu mnuFileExit
            Shortcut = ^{F4}
        END
        BEGIN Menu mnuEditCut
            Shortcut = ^X
        END
        BEGIN Menu mnuEditCopy
            Shortcut = ^C
        END
    END
END
FRM

  my $items = $ast->{form}{children}[0]{children};
  is_deeply( [ map { $_->{properties}{Shortcut} } @$items ],
    [ '^{F4}', '^X', '^C' ],
    'preserves function-key and letter shortcuts from BookLook' );
};

subtest 'custom control properties and nested controls' => sub {
  my $ast = $parser->from_string( <<'FRM' );
Version 1.00
BEGIN Form frmSpinExample
    BEGIN Frame Frame1
        BEGIN Custom VSpin
            Column = 3
            Filename = "SPIN.DAT"
            Mode = 2
            BEGIN TextBox Text1
                Text = "0"
            END
            BEGIN Custom HSpin
                Row = 4
            END
        END
    END
END
FRM

  my $custom = $ast->{form}{children}[0]{children}[0];
  is_deeply( $custom->{properties},
    { Column => 3, Filename => 'SPIN.DAT', Mode => 2 },
    'preserves library-defined property names and values' );
  is( $custom->{children}[0]{properties}{Text}, '0',
    'parses a standard child of a custom control' );
  is( $custom->{children}[1]{properties}{Row}, 4,
    'parses a nested custom control and its properties' );

  my $invalid = <<'FRM';
Version 1.00
BEGIN Form Form1
    BEGIN Custom VSpin
        BEGIN TextBox Text1
            Column = 3
        END
    END
END
FRM
  my $ok = eval { $parser->from_string( $invalid ); 1 };
  ok( !$ok, 'a standard child still rejects unknown properties' );
};

subtest 'errors retain their location in nested blocks' => sub {
  my @cases = (
    {
      name => 'invalid value in a nested menu',
      input => <<'FRM',
Version 1.00
BEGIN MDIForm frmBooklook
    BEGIN Menu mnuFile
        BEGIN Menu mnuFileExit
            Shortcut = ^{F4
        END
    END
END
FRM
      line => 5,
      text => 'Shortcut = ^{F4',
    },
    {
      name => 'missing equals in a nested control',
      input => <<'FRM',
Version 1.00
BEGIN Form Form1
    BEGIN Frame Frame1
        BEGIN TextBox Text1
            Text "Hello"
        END
    END
END
FRM
      line => 5,
      text => 'Text "Hello"',
    },
    {
      name => 'unknown control type',
      input => <<'FRM',
Version 1.00
BEGIN Form Form1
    BEGIN Unknown Control1
    END
END
FRM
      line => 3,
      text => 'BEGIN Unknown Control1',
    },
  );

  for my $case ( @cases ) {
    my $ok = eval { $parser->from_string( $case->{input} ); 1 };
    my $error = "$@";
    ok( !$ok, "$case->{name} fails" );
    like( $error, qr/on line $case->{line} at:/,
      "$case->{name} reports the relevant line" );
    like( $error, qr/\Q$case->{text}\E/,
      "$case->{name} includes the offending text" );
  }
};

done_testing();
