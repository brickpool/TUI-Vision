package TUI::Drivers::HardwareInfo::Termbox;
# ABSTRACT: Termbox driver for TUI::Drivers::HardwareInfo

# -------------------------------------------------------------------------
# Boilerplate
# -------------------------------------------------------------------------

use 5.010;
use strict;
use warnings;

our $VERSION = '0.001000';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

# -------------------------------------------------------------------------
# Import modules
# -------------------------------------------------------------------------

BEGIN { sub FFI () { eval { require Termbox; Termbox->VERSION(2); 1 } } }

use PerlX::Assert::PP;
use English qw( -no_match_vars );
use Errno qw( EINTR );
use Scalar::Util qw(
  blessed
  looks_like_number
  readonly
);
use if !FFI, 'Termbox::PP';
use Termbox qw( :all );
use Time::HiRes qw( time );
use TUI::toolkit::boolean;

use TUI::Drivers::Const qw(
  evKeyDown
  :smXXXX
  :kbXXXX
  :meXXXX
  :mbXXXX
);

# -------------------------------------------------------------------------
# Define constants
# -------------------------------------------------------------------------

use constant TB_NONE => 0;
use constant ESC_WAIT_DELAY => 100; # ms

# -------------------------------------------------------------------------
# Declare global variables
# -------------------------------------------------------------------------

our $insertState  = true;
our $platform     = '';
our $pendingEvent = 0;

# Track mouse button state for double-click detection.
our $lastButtons = 0;
our $downButtons = 0;
our $lastDouble  = false;
our @lastWhere   = ( 0, 0 );
our @downWhere   = ( 0, 0 );
our $downTicks   = 0;
our $doubleDelay = 8;

# -------------------------------------------------------------------------
# Import global variables
# -------------------------------------------------------------------------

use vars qw(
  $ctrlBreakHit
);
{
  no warnings 'once';
  *ctrlBreakHit = \$TUI::Drivers::SystemError::ctrlBreakHit;
}

# -------------------------------------------------------------------------
# Local variables
# -------------------------------------------------------------------------

my $initialized = false;
my $cursorLines = 0x0607;
my $tb_event = Termbox::Event->new();

# Codepage 437 to Unicode translation map.
my @CP437_TO_UTF8 = (
  ord "\x{2007}", ord "\x{263a}", ord "\x{263b}", ord "\x{2665}",
  ord "\x{2666}", ord "\x{2663}", ord "\x{2660}", ord "\x{2022}",
  ord "\x{25d8}", ord "\x{25cb}", ord "\x{25d9}", ord "\x{2642}",
  ord "\x{2640}", ord "\x{266a}", ord "\x{266b}", ord "\x{263c}",
  # Termius has 25b6 and 25c0 here, which are better unicode equivalents.
  # ord "\x{25ba}", ord "\x{25c4}", ord "\x{2195}", ord "\x{203c}",
  ord "\x{25b6}", ord "\x{25c0}", ord "\x{2195}", ord "\x{203c}",
  ord "\x{00b6}", ord "\x{00a7}", ord "\x{25ac}", ord "\x{21a8}",
  ord "\x{2191}", ord "\x{2193}", ord "\x{2192}", ord "\x{2190}",
  ord "\x{221f}", ord "\x{2194}", ord "\x{25b2}", ord "\x{25bc}",
  ord "\x{0020}", ord "\x{0021}", ord "\x{0022}", ord "\x{0023}",
  ord "\x{0024}", ord "\x{0025}", ord "\x{0026}", ord "\x{0027}",
  ord "\x{0028}", ord "\x{0029}", ord "\x{002a}", ord "\x{002b}",
  ord "\x{002c}", ord "\x{002d}", ord "\x{002e}", ord "\x{002f}",
  ord "\x{0030}", ord "\x{0031}", ord "\x{0032}", ord "\x{0033}",
  ord "\x{0034}", ord "\x{0035}", ord "\x{0036}", ord "\x{0037}",
  ord "\x{0038}", ord "\x{0039}", ord "\x{003a}", ord "\x{003b}",
  ord "\x{003c}", ord "\x{003d}", ord "\x{003e}", ord "\x{003f}",
  ord "\x{0040}", ord "\x{0041}", ord "\x{0042}", ord "\x{0043}",
  ord "\x{0044}", ord "\x{0045}", ord "\x{0046}", ord "\x{0047}",
  ord "\x{0048}", ord "\x{0049}", ord "\x{004a}", ord "\x{004b}",
  ord "\x{004c}", ord "\x{004d}", ord "\x{004e}", ord "\x{004f}",
  ord "\x{0050}", ord "\x{0051}", ord "\x{0052}", ord "\x{0053}",
  ord "\x{0054}", ord "\x{0055}", ord "\x{0056}", ord "\x{0057}",
  ord "\x{0058}", ord "\x{0059}", ord "\x{005a}", ord "\x{005b}",
  ord "\x{005c}", ord "\x{005d}", ord "\x{005e}", ord "\x{005f}",
  ord "\x{0060}", ord "\x{0061}", ord "\x{0062}", ord "\x{0063}",
  ord "\x{0064}", ord "\x{0065}", ord "\x{0066}", ord "\x{0067}",
  ord "\x{0068}", ord "\x{0069}", ord "\x{006a}", ord "\x{006b}",
  ord "\x{006c}", ord "\x{006d}", ord "\x{006e}", ord "\x{006f}",
  ord "\x{0070}", ord "\x{0071}", ord "\x{0072}", ord "\x{0073}",
  ord "\x{0074}", ord "\x{0075}", ord "\x{0076}", ord "\x{0077}",
  ord "\x{0078}", ord "\x{0079}", ord "\x{007a}", ord "\x{007b}",
  ord "\x{007c}", ord "\x{007d}", ord "\x{007e}", ord "\x{2302}",
  ord "\x{00c7}", ord "\x{00fc}", ord "\x{00e9}", ord "\x{00e2}",
  ord "\x{00e4}", ord "\x{00e0}", ord "\x{00e5}", ord "\x{00e7}",
  ord "\x{00ea}", ord "\x{00eb}", ord "\x{00e8}", ord "\x{00ef}",
  ord "\x{00ee}", ord "\x{00ec}", ord "\x{00c4}", ord "\x{00c5}",
  ord "\x{00c9}", ord "\x{00e6}", ord "\x{00c6}", ord "\x{00f4}",
  ord "\x{00f6}", ord "\x{00f2}", ord "\x{00fb}", ord "\x{00f9}",
  ord "\x{00ff}", ord "\x{00d6}", ord "\x{00dc}", ord "\x{00a2}",
  ord "\x{00a3}", ord "\x{00a5}", ord "\x{20a7}", ord "\x{0192}",
  ord "\x{00e1}", ord "\x{00ed}", ord "\x{00f3}", ord "\x{00fa}",
  ord "\x{00f1}", ord "\x{00d1}", ord "\x{00aa}", ord "\x{00ba}",
  ord "\x{00bf}", ord "\x{2310}", ord "\x{00ac}", ord "\x{00bd}",
  ord "\x{00bc}", ord "\x{00a1}", ord "\x{00ab}", ord "\x{00bb}",
  ord "\x{2591}", ord "\x{2592}", ord "\x{2593}", ord "\x{2502}",
  ord "\x{2524}", ord "\x{2561}", ord "\x{2562}", ord "\x{2556}",
  ord "\x{2555}", ord "\x{2563}", ord "\x{2551}", ord "\x{2557}",
  ord "\x{255d}", ord "\x{255c}", ord "\x{255b}", ord "\x{2510}",
  ord "\x{2514}", ord "\x{2534}", ord "\x{252c}", ord "\x{251c}",
  ord "\x{2500}", ord "\x{253c}", ord "\x{255e}", ord "\x{255f}",
  ord "\x{255a}", ord "\x{2554}", ord "\x{2569}", ord "\x{2566}",
  ord "\x{2560}", ord "\x{2550}", ord "\x{256c}", ord "\x{2567}",
  ord "\x{2568}", ord "\x{2564}", ord "\x{2565}", ord "\x{2559}",
  ord "\x{2558}", ord "\x{2552}", ord "\x{2553}", ord "\x{256b}",
  ord "\x{256a}", ord "\x{2518}", ord "\x{250c}", ord "\x{2588}",
  ord "\x{2584}", ord "\x{258c}", ord "\x{2590}", ord "\x{2580}",
  ord "\x{03b1}", ord "\x{00df}", ord "\x{0393}", ord "\x{03c0}",
  ord "\x{03a3}", ord "\x{03c3}", ord "\x{00b5}", ord "\x{03c4}",
  ord "\x{03a6}", ord "\x{0398}", ord "\x{03a9}", ord "\x{03b4}",
  ord "\x{221e}", ord "\x{03c6}", ord "\x{03b5}", ord "\x{2229}",
  ord "\x{2261}", ord "\x{00b1}", ord "\x{2265}", ord "\x{2264}",
  ord "\x{2320}", ord "\x{2321}", ord "\x{00f7}", ord "\x{2248}",
  ord "\x{00b0}", ord "\x{2219}", ord "\x{00b7}", ord "\x{221a}",
  ord "\x{207f}", ord "\x{00b2}", ord "\x{25a0}", ord "\x{00a0}",
);

# [ mod, key, ch ]
my %TV_TO_TB = (
  # Control keys
  kbCtrlA() => [ TB_MOD_CTRL, TB_KEY_CTRL_A, 0 ],
  kbCtrlB() => [ TB_MOD_CTRL, TB_KEY_CTRL_B, 0 ],
  kbCtrlC() => [ TB_MOD_CTRL, TB_KEY_CTRL_C, 0 ],
  kbCtrlD() => [ TB_MOD_CTRL, TB_KEY_CTRL_D, 0 ],
  kbCtrlE() => [ TB_MOD_CTRL, TB_KEY_CTRL_E, 0 ],
  kbCtrlF() => [ TB_MOD_CTRL, TB_KEY_CTRL_F, 0 ],
  kbCtrlG() => [ TB_MOD_CTRL, TB_KEY_CTRL_G, 0 ],
  kbCtrlH() => [ TB_MOD_CTRL, TB_KEY_CTRL_H, 0 ],
  kbCtrlI() => [ TB_MOD_CTRL, TB_KEY_CTRL_I, 0 ],
  kbCtrlJ() => [ TB_MOD_CTRL, TB_KEY_CTRL_J, 0 ],
  kbCtrlK() => [ TB_MOD_CTRL, TB_KEY_CTRL_K, 0 ],
  kbCtrlL() => [ TB_MOD_CTRL, TB_KEY_CTRL_L, 0 ],
  kbCtrlM() => [ TB_MOD_CTRL, TB_KEY_CTRL_M, 0 ],
  kbCtrlN() => [ TB_MOD_CTRL, TB_KEY_CTRL_N, 0 ],
  kbCtrlO() => [ TB_MOD_CTRL, TB_KEY_CTRL_O, 0 ],
  kbCtrlP() => [ TB_MOD_CTRL, TB_KEY_CTRL_P, 0 ],
  kbCtrlQ() => [ TB_MOD_CTRL, TB_KEY_CTRL_Q, 0 ],
  kbCtrlR() => [ TB_MOD_CTRL, TB_KEY_CTRL_R, 0 ],
  kbCtrlS() => [ TB_MOD_CTRL, TB_KEY_CTRL_S, 0 ],
  kbCtrlT() => [ TB_MOD_CTRL, TB_KEY_CTRL_T, 0 ],
  kbCtrlU() => [ TB_MOD_CTRL, TB_KEY_CTRL_U, 0 ],
  kbCtrlV() => [ TB_MOD_CTRL, TB_KEY_CTRL_V, 0 ],
  kbCtrlW() => [ TB_MOD_CTRL, TB_KEY_CTRL_W, 0 ],
  kbCtrlX() => [ TB_MOD_CTRL, TB_KEY_CTRL_X, 0 ],
  kbCtrlY() => [ TB_MOD_CTRL, TB_KEY_CTRL_Y, 0 ],
  kbCtrlZ() => [ TB_MOD_CTRL, TB_KEY_CTRL_Z, 0 ],

  # Extended key codes
  kbEsc()       => [ TB_NONE,      TB_KEY_ESC,         0 ],
  kbAltSpace()  => [ TB_MOD_ALT,   TB_KEY_SPACE,       0 ],

  kbCtrlIns()   => [ TB_MOD_CTRL,  TB_KEY_INSERT,      0 ],
  kbShiftIns()  => [ TB_MOD_SHIFT, TB_KEY_INSERT,      0 ],

  kbCtrlDel()   => [ TB_MOD_CTRL,  TB_KEY_DELETE,      0 ],
  kbShiftDel()  => [ TB_MOD_SHIFT, TB_KEY_DELETE,      0 ],

  kbBack()      => [ TB_MOD_CTRL,  TB_KEY_BACKSPACE2,  0 ],
  kbCtrlBack()  => [ TB_MOD_CTRL,  TB_KEY_BACKSPACE,   0 ],

  kbShiftTab()  => [ TB_MOD_SHIFT, TB_KEY_BACK_TAB,    0 ],
  kbTab()       => [ TB_NONE,      TB_KEY_TAB,         0 ],

  kbCtrlEnter() => [ TB_MOD_CTRL,  TB_KEY_CTRL_J,      0 ],
  kbEnter()     => [ TB_MOD_CTRL,  TB_KEY_ENTER,       0 ],

  # Alt letters
  kbAltQ()      => [ TB_MOD_ALT, 0, ord('q') ],
  kbAltW()      => [ TB_MOD_ALT, 0, ord('w') ],
  kbAltE()      => [ TB_MOD_ALT, 0, ord('e') ],
  kbAltR()      => [ TB_MOD_ALT, 0, ord('r') ],
  kbAltT()      => [ TB_MOD_ALT, 0, ord('t') ],
  kbAltY()      => [ TB_MOD_ALT, 0, ord('y') ],
  kbAltU()      => [ TB_MOD_ALT, 0, ord('u') ],
  kbAltI()      => [ TB_MOD_ALT, 0, ord('i') ],
  kbAltO()      => [ TB_MOD_ALT, 0, ord('o') ],
  kbAltP()      => [ TB_MOD_ALT, 0, ord('p') ],

  kbAltA()      => [ TB_MOD_ALT, 0, ord('a') ],
  kbAltS()      => [ TB_MOD_ALT, 0, ord('s') ],
  kbAltD()      => [ TB_MOD_ALT, 0, ord('d') ],
  kbAltF()      => [ TB_MOD_ALT, 0, ord('f') ],
  kbAltG()      => [ TB_MOD_ALT, 0, ord('g') ],
  kbAltH()      => [ TB_MOD_ALT, 0, ord('h') ],
  kbAltJ()      => [ TB_MOD_ALT, 0, ord('j') ],
  kbAltK()      => [ TB_MOD_ALT, 0, ord('k') ],
  kbAltL()      => [ TB_MOD_ALT, 0, ord('l') ],

  kbAltZ()      => [ TB_MOD_ALT, 0, ord('z') ],
  kbAltX()      => [ TB_MOD_ALT, 0, ord('x') ],
  kbAltC()      => [ TB_MOD_ALT, 0, ord('c') ],
  kbAltV()      => [ TB_MOD_ALT, 0, ord('v') ],
  kbAltB()      => [ TB_MOD_ALT, 0, ord('b') ],
  kbAltN()      => [ TB_MOD_ALT, 0, ord('n') ],
  kbAltM()      => [ TB_MOD_ALT, 0, ord('m') ],

  # Function keys
  kbF1()        => [ TB_NONE,      TB_KEY_F1,          0 ],
  kbF2()        => [ TB_NONE,      TB_KEY_F2,          0 ],
  kbF3()        => [ TB_NONE,      TB_KEY_F3,          0 ],
  kbF4()        => [ TB_NONE,      TB_KEY_F4,          0 ],
  kbF5()        => [ TB_NONE,      TB_KEY_F5,          0 ],
  kbF6()        => [ TB_NONE,      TB_KEY_F6,          0 ],
  kbF7()        => [ TB_NONE,      TB_KEY_F7,          0 ],
  kbF8()        => [ TB_NONE,      TB_KEY_F8,          0 ],
  kbF9()        => [ TB_NONE,      TB_KEY_F9,          0 ],
  kbF10()       => [ TB_NONE,      TB_KEY_F10,         0 ],
  kbF11()       => [ TB_NONE,      TB_KEY_F11,         0 ],
  kbF12()       => [ TB_NONE,      TB_KEY_F12,         0 ],

  kbShiftF1()   => [ TB_MOD_SHIFT, TB_KEY_F1,          0 ],
  kbShiftF2()   => [ TB_MOD_SHIFT, TB_KEY_F2,          0 ],
  kbShiftF3()   => [ TB_MOD_SHIFT, TB_KEY_F3,          0 ],
  kbShiftF4()   => [ TB_MOD_SHIFT, TB_KEY_F4,          0 ],
  kbShiftF5()   => [ TB_MOD_SHIFT, TB_KEY_F5,          0 ],
  kbShiftF6()   => [ TB_MOD_SHIFT, TB_KEY_F6,          0 ],
  kbShiftF7()   => [ TB_MOD_SHIFT, TB_KEY_F7,          0 ],
  kbShiftF8()   => [ TB_MOD_SHIFT, TB_KEY_F8,          0 ],
  kbShiftF9()   => [ TB_MOD_SHIFT, TB_KEY_F9,          0 ],
  kbShiftF10()  => [ TB_MOD_SHIFT, TB_KEY_F10,         0 ],
  kbShiftF11()  => [ TB_MOD_SHIFT, TB_KEY_F11,         0 ],
  kbShiftF12()  => [ TB_MOD_SHIFT, TB_KEY_F12,         0 ],

  kbCtrlF1()    => [ TB_MOD_CTRL,  TB_KEY_F1,          0 ],
  kbCtrlF2()    => [ TB_MOD_CTRL,  TB_KEY_F2,          0 ],
  kbCtrlF3()    => [ TB_MOD_CTRL,  TB_KEY_F3,          0 ],
  kbCtrlF4()    => [ TB_MOD_CTRL,  TB_KEY_F4,          0 ],
  kbCtrlF5()    => [ TB_MOD_CTRL,  TB_KEY_F5,          0 ],
  kbCtrlF6()    => [ TB_MOD_CTRL,  TB_KEY_F6,          0 ],
  kbCtrlF7()    => [ TB_MOD_CTRL,  TB_KEY_F7,          0 ],
  kbCtrlF8()    => [ TB_MOD_CTRL,  TB_KEY_F8,          0 ],
  kbCtrlF9()    => [ TB_MOD_CTRL,  TB_KEY_F9,          0 ],
  kbCtrlF10()   => [ TB_MOD_CTRL,  TB_KEY_F10,         0 ],
  kbCtrlF11()   => [ TB_MOD_CTRL,  TB_KEY_F11,         0 ],
  kbCtrlF12()   => [ TB_MOD_CTRL,  TB_KEY_F12,         0 ],

  kbAltF1()     => [ TB_MOD_ALT,   TB_KEY_F1,          0 ],
  kbAltF2()     => [ TB_MOD_ALT,   TB_KEY_F2,          0 ],
  kbAltF3()     => [ TB_MOD_ALT,   TB_KEY_F3,          0 ],
  kbAltF4()     => [ TB_MOD_ALT,   TB_KEY_F4,          0 ],
  kbAltF5()     => [ TB_MOD_ALT,   TB_KEY_F5,          0 ],
  kbAltF6()     => [ TB_MOD_ALT,   TB_KEY_F6,          0 ],
  kbAltF7()     => [ TB_MOD_ALT,   TB_KEY_F7,          0 ],
  kbAltF8()     => [ TB_MOD_ALT,   TB_KEY_F8,          0 ],
  kbAltF9()     => [ TB_MOD_ALT,   TB_KEY_F9,          0 ],
  kbAltF10()    => [ TB_MOD_ALT,   TB_KEY_F10,         0 ],
  kbAltF11()    => [ TB_MOD_ALT,   TB_KEY_F11,         0 ],
  kbAltF12()    => [ TB_MOD_ALT,   TB_KEY_F12,         0 ],

  # Navigation
  kbHome()      => [ TB_NONE,      TB_KEY_HOME,        0 ],
  kbEnd()       => [ TB_NONE,      TB_KEY_END,         0 ],

  kbPgUp()      => [ TB_NONE,      TB_KEY_PGUP,        0 ],
  kbPgDn()      => [ TB_NONE,      TB_KEY_PGDN,        0 ],

  kbUp()        => [ TB_NONE,      TB_KEY_ARROW_UP,    0 ],
  kbDown()      => [ TB_NONE,      TB_KEY_ARROW_DOWN,  0 ],
  kbLeft()      => [ TB_NONE,      TB_KEY_ARROW_LEFT,  0 ],
  kbRight()     => [ TB_NONE,      TB_KEY_ARROW_RIGHT, 0 ],

  kbCtrlLeft()  => [ TB_MOD_CTRL,  TB_KEY_ARROW_LEFT,  0 ],
  kbCtrlRight() => [ TB_MOD_CTRL,  TB_KEY_ARROW_RIGHT, 0 ],

  kbCtrlHome()  => [ TB_MOD_CTRL,  TB_KEY_HOME,        0 ],
  kbCtrlEnd()   => [ TB_MOD_CTRL,  TB_KEY_END,         0 ],

  kbCtrlPgUp()  => [ TB_MOD_CTRL,  TB_KEY_PGUP,        0 ],
  kbCtrlPgDn()  => [ TB_MOD_CTRL,  TB_KEY_PGDN,        0 ],

  kbIns()       => [ TB_NONE,      TB_KEY_INSERT,      0 ],
  kbDel()       => [ TB_NONE,      TB_KEY_DELETE,      0 ],

  # Alt digits
  kbAlt1()      => [ TB_MOD_ALT, 0, ord('1') ],
  kbAlt2()      => [ TB_MOD_ALT, 0, ord('2') ],
  kbAlt3()      => [ TB_MOD_ALT, 0, ord('3') ],
  kbAlt4()      => [ TB_MOD_ALT, 0, ord('4') ],
  kbAlt5()      => [ TB_MOD_ALT, 0, ord('5') ],
  kbAlt6()      => [ TB_MOD_ALT, 0, ord('6') ],
  kbAlt7()      => [ TB_MOD_ALT, 0, ord('7') ],
  kbAlt8()      => [ TB_MOD_ALT, 0, ord('8') ],
  kbAlt9()      => [ TB_MOD_ALT, 0, ord('9') ],
  kbAlt0()      => [ TB_MOD_ALT, 0, ord('0') ],

  kbAltMinus()  => [ TB_MOD_ALT, 0, ord('-') ],
  kbAltEqual()  => [ TB_MOD_ALT, 0, ord('=') ],

  kbAltBack()   => [
                      TB_MOD_ALT | TB_MOD_CTRL,
                      TB_KEY_BACKSPACE2,
                      0
                    ],

  kbNoKey()     => [ TB_NONE, 0, 0 ],

  # kbGrayMinus() => collides with '-'
  # kbGrayPlus()  => collides with '+'
  # kbCtrlPrtSc() => no event generated (effectively collides with kbNoKey())
);

# -------------------------------------------------------------------------
# Initialization and cleanup
# -------------------------------------------------------------------------

INIT {
  # Determine the platform type for compatibility with TUI::Drivers::SystemInfo.
  if ( eval { require Perl::OSType; 1 } ) {
    $platform = Perl::OSType::os_type( $OSNAME );
  } elsif ( $OSNAME eq 'MSWin32' ) {
    $platform = 'Windows';
  }
  $platform ||= 'Unix';

  # Initialize Termbox and set the input/output modes.
  my $err = tb_init();
  die tb_strerror( $err ) if $err != TB_OK;
  $err = tb_set_input_mode( TB_INPUT_ALT | TB_INPUT_MOUSE );
  die tb_strerror( $err ) if $err != TB_OK;
  $err = tb_set_output_mode( TB_OUTPUT_NORMAL );
  die tb_strerror( $err ) if $err != TB_OK;

  # NOTE: The following workaround for detecting a single TB_KEY_ESC relies on 
  # deprecated function tb_set_func() and Termbox::PP internals 
  # ($global->{inbuf}). 
  # The tb_set_func() API itself is backend-independent, but the raw
  # escape buffer is currently only available in the PP backend.
  unless (FFI) {
    no warnings 'deprecated';
    $err = tb_set_func( TB_FUNC_EXTRACT_PRE, sub {
      my ( $event, $consumed_ref ) = @_;

      state $esc_seen_at;
      if ( $Termbox::global->{inbuf} eq "\e" ) {
        my $now = int(( time() - $BASETIME ) * 1000);
        $esc_seen_at //= $now;
        my $elapsed = $now - $esc_seen_at;

        return TB_ERR_NEED_MORE
          if $elapsed < ESC_WAIT_DELAY;

        $$consumed_ref = 1;

        $event->{type} = TB_EVENT_KEY;
        $event->{mod}  = TB_NONE;
        $event->{key}  = TB_KEY_ESC;
        $event->{ch}   = 0;

        $esc_seen_at = undef;
        return TB_OK;
      }
      $esc_seen_at = undef;
      return TB_ERR;
    });
    die tb_strerror( $err ) if $err != TB_OK;
  }

  $initialized = true;
}

END {
  if ($initialized) {
    tb_set_func( TB_FUNC_EXTRACT_PRE, undef ) unless FFI;
    tb_shutdown();
  }
}

# -------------------------------------------------------------------------
# General system functions
# -------------------------------------------------------------------------

sub getTickCount {    # $ticks ($class)
  assert ( $_[0] and !ref $_[0] );
  # Return Turbo Vision compatible clock ticks (~18.2 Hz).
  return int( ( time() - $BASETIME ) * 1000 / 55 );
}

sub getPlatform {     # $osname ($class)
  assert ( $_[0] and !ref $_[0] );
  return $platform;
}

# -------------------------------------------------------------------------
# Caret functions
# -------------------------------------------------------------------------

sub setCaretSize {    # void ($class, $size)
  my ( $class, $size ) = @_;
  assert ( $class and !ref $class );
  assert ( looks_like_number $size );
  if ( $size <= 0 ) {
    $cursorLines = 0x2000;    # hidden
    tb_hide_cursor();
  } elsif ( $size > 0 ) {
    # 1..99 -> BIOS-style cursor shape
    my $scan_row_start = 0x07 - int( $size * 7.0 / (100 - 1) + 0.5 );
    my $scan_row_end = 0x07;
    $cursorLines = $scan_row_start << 8 | $scan_row_end;

    # Show cursor; (-1,-1) is clamped to (0,0).
    tb_set_cursor( -1, -1 );
  }
  return;
}

sub getCaretSize {    # $size ($class)
  assert ( $_[0] and !ref $_[0] );

  return 0 if $cursorLines & 0x2000;

  my $scan_row_start = $cursorLines >> 8 & 0xff;
  my $scan_row_end   = $cursorLines & 0xff;

  my $size = int(($scan_row_end - $scan_row_start) / 7.0 * (100 - 1) + 0.5) + 1;
  $size = 15  if $size < 1;
  $size = 50  if $size == 58;
  $size = 100 if $size > 100;

  return $size;
}

sub setCaretPosition {    # void ($class, $x, $y)
  my ( $class, $x, $y ) = @_;
  assert ( $class and !ref $class );
  assert ( looks_like_number $x );
  assert ( looks_like_number $y );
  tb_set_cursor( $x, $y );
  return;
}

sub isCaretVisible {    # $visible ($class)
  assert ( $_[0] and !ref $_[0] );
  return not (
    ($cursorLines & 0x2000)
      ||
    (($cursorLines >> 8) > ($cursorLines & 0xff))
  );
}

# -------------------------------------------------------------------------
# Screen functions
# -------------------------------------------------------------------------

sub getScreenRows {    # $rows ($class)
  assert ( $_[0] and !ref $_[0] );
  my $rows = tb_height();
  return 25 
    if $rows == 0;    # Borland's compatibility DOS default (only for rows)
  return $rows > 0 ? $rows : 0;
}

sub getScreenCols {       # $cols ($class)
  assert ( $_[0] and !ref $_[0] );
  my $cols = tb_width();
  return $cols > 0 ? $cols : 0;
}

sub getScreenMode {       # $mode ($class)
  assert ( $_[0] and !ref $_[0] );
  my $rows = tb_height();
  my $mode = 0;
  if ( $rows > 0 ) {
    $mode = tb_set_output_mode(TB_OUTPUT_CURRENT) == TB_OUTPUT_GRAYSCALE
          ? smBW80
          : smCO80;
  }
  $mode |= smFont8x8 if $rows > 25;
  return $mode;
}

sub setScreenMode {       # void ($class, $mode)
  my ( $class, $mode ) = @_;
  assert ( $class and !ref $class );
  assert ( looks_like_number $mode );
  $mode &= ~smFont8x8;
  tb_set_output_mode(
    $mode == smBW80
      ? TB_OUTPUT_GRAYSCALE
      : TB_OUTPUT_NORMAL
  );
  return;
}

sub clearScreen {         # void ($class, $w, $h)
  my ( $class, $w, $h ) = @_;
  assert ( $class and !ref $class );
  assert ( looks_like_number $w );
  assert ( looks_like_number $h );
  tb_clear();
  return;
}

sub screenWrite {         # void ($class, $x, $y, $buf, $len)
  my ( $class, $x, $y, $buf, $len ) = @_;
  assert ( $class and !ref $class );
  assert ( looks_like_number $x );
  assert ( looks_like_number $y );
  assert ( ref $buf );
  assert ( looks_like_number $len );

  state %TB_ATTR;
  for ( my $i = 0 ; $i < $len ; ++$i, ++$x ) {
    my $screenCell = $buf->[$i];
    my $colorAttr = $TB_ATTR{ $screenCell->[1] } //= 
      _bios_attr_to_tb_attr( $screenCell->[1] );

    tb_set_cell(
      $x, $y,
      chr( $CP437_TO_UTF8[ $screenCell->[0] & 0xff ] ),
      $colorAttr->[0],    # fg
      $colorAttr->[1],    # bg
    );
  }

  tb_present();
  return;
}

sub allocateScreenBuffer {    # \@buffer ($class)
  assert ( $_[0] and !ref $_[0] );

  my $cols = tb_width();
  my $rows = tb_height();

  return []
    if $cols <= 0 || $rows <= 0;

  # Make sure we allocate at least enough for a 80x50 screen.
  $cols = 80 if $cols < 80;
  $rows = 50 if $rows < 50;

  return [ map [ 0, 0 ], 1 .. $cols * $rows ];
}

sub freeScreenBuffer {        # void ($class, \@buffer)
  assert ( $_[0] and !ref $_[0] );
  assert ( ref $_[1] and !readonly @{ $_[1] } );
  $_[1] = [];
  return;
}

# -------------------------------------------------------------------------
# Mouse functions
# -------------------------------------------------------------------------

sub getButtonCount {    # $num ($class)
  assert ( $_[0] and !ref $_[0] );

  # Termbox reports mouse events, but not a physical button count.
  # Return a practical compatibility value.
  return 3;
}

sub cursorOn {    # void ($class)
  assert ( $_[0] and !ref $_[0] );
  my $mode = tb_set_input_mode( TB_INPUT_CURRENT );
  tb_set_input_mode( $mode | TB_INPUT_MOUSE );
  return;
}

sub cursorOff {    # void ($class)
  assert ( $_[0] and !ref $_[0] );
  my $mode = tb_set_input_mode( TB_INPUT_CURRENT );
  tb_set_input_mode( $mode & ~TB_INPUT_MOUSE );
  return;
}

# -------------------------------------------------------------------------
# Event functions
# -------------------------------------------------------------------------

sub clearPendingEvent {    # void ($class)
  assert ( $_[0] and !ref $_[0] );
  $pendingEvent = 0;
  return;
}

sub getMouseEvent {    # $bool ($class, $event)
  my ( $class, $event ) = @_;
  assert ( $class and !ref $class );
  assert ( blessed $event );

  # Check for pending events
  unless ($pendingEvent) {
    my $rv = tb_peek_event( $tb_event, 0 );
    $pendingEvent = 1 if $rv == TB_OK;
  }

  # Return false if there are no pending events
  return false
    unless $pendingEvent;

  # Handle resize events immediately
  if ($tb_event->type == TB_EVENT_RESIZE ) {
    tb_invalidate();
    $pendingEvent = 0;
    return false;
  }

  # Return if the event is not a mouse event
  return false
    if $tb_event->type != TB_EVENT_MOUSE;

  # Track the state of mouse buttons
  my $buttons = $lastButtons;
  if ( $tb_event->key == TB_KEY_MOUSE_LEFT ) {
    $buttons |= mbLeftButton;
  }
  elsif ( $tb_event->key == TB_KEY_MOUSE_RIGHT ) {
    $buttons |= mbRightButton;
  }
  elsif ( $tb_event->key == TB_KEY_MOUSE_RELEASE ) {
    $buttons = 0;
  }

  # Detect double-clicks
  my @where = ( $tb_event->x, $tb_event->y );
  my $doubleClick = false;
  if ( $buttons != 0 && $lastButtons == 0 ) {
    my $ticks = getTickCount();
    $doubleClick = !(
      $buttons != $downButtons
        or
      $where[0] != $downWhere[0] || $where[1] != $downWhere[1]
        or
      $ticks - $downTicks >= $doubleDelay
    );
    $downButtons = $buttons;
    @downWhere   = @where;
    $downTicks   = $ticks;
  }

  # Mouse position
  $event->{where}{x} = $where[0];
  $event->{where}{y} = $where[1];

  # Button state
  $event->{buttons} = $buttons;

  # Event flags
  $event->{eventFlags} = 0;
  $event->{eventFlags} |= meMouseMoved
    if $tb_event->mod & TB_MOD_MOTION;
  $event->{eventFlags} |= meDoubleClick
    if $doubleClick;

  # Mouse modifier state.
  $event->{keyDown}{controlKeyState} = $insertState ? kbInsState : 0;

  # Save the last button state and position for double-click detection
  $lastButtons = $buttons;
  @lastWhere   = @where;
  $lastDouble  = $doubleClick;

  # Clear the pending event flag because we have consumed the event
  $pendingEvent = 0;
  return true;
}

sub getKeyEvent {    # $bool ($class, $event)
  my ( $class, $event ) = @_;
  assert ( $class and !ref $class );
  assert ( blessed $event );

  # Check for pending events
  unless ($pendingEvent) {
    my $rv = tb_peek_event( $tb_event, 0 );
    $pendingEvent = 1 if $rv == TB_OK;
  }

  # Return false if there are no pending events
  return false
    unless $pendingEvent;

  # Handle resize events immediately
  if ( $tb_event->type == TB_EVENT_RESIZE ) {
    tb_invalidate();
    $pendingEvent = 0;
    return false;
  }

  # Return if the event is not a key event
  return false
    if $tb_event->type != TB_EVENT_KEY;

  $event->{what} = evKeyDown;

  # Set the key code and character code in the event structure.
  my $keyCode = _tb_event_to_key_code($tb_event);
  $event->{keyDown}{keyCode} = $keyCode;
  if ( $keyCode == kbNoKey ) {
    my $charCode = _tb_event_to_char_code( $tb_event );
    $event->{keyDown}{charScan}{charCode} = $charCode;
  }
  elsif ( $keyCode == kbIns ) {
    $insertState = !$insertState;
  }

  # Update the shift state and control key state in the event structure
  my $shiftState = 0;
  $shiftState |= kbAltShift
    if $tb_event->mod & TB_MOD_ALT;
  $shiftState |= kbCtrlShift
    if $tb_event->mod & TB_MOD_CTRL;
  $shiftState |= kbShift
    if $tb_event->mod & TB_MOD_SHIFT;
  $shiftState |= kbInsState
    if $insertState;
  $event->{keyDown}{controlKeyState} = $shiftState;

  # Set the Ctrl-Break flag if Ctrl-C was pressed
  $ctrlBreakHit ||= $event->{keyDown}{keyCode} == kbCtrlC;

  $pendingEvent = 0;
  return true;
}

# -------------------------------------------------------------------------
# System functions
# -------------------------------------------------------------------------

sub setCtrlBrkHandler {    # $success ($class, $install)
  my ( $class, $install ) = @_;
  assert ( @_ == 2 );
  assert ( $class and !ref $class );
  assert ( !defined $install or !ref $install );
  # Termbox handles terminal input itself. No direct Ctrl-Break handler.
  return true;
}

sub setCritErrorHandler {    # $bool ($class, $install)
  assert ( @_ == 2 );
  assert ( $_[0] and !ref $_[0] );
  assert ( !defined $_[1] or !ref $_[1] );
  # Not applicable for Termbox.
  return true;
}

# -------------------------------------------------------------------------
# Private helper functions
# -------------------------------------------------------------------------

sub _bios_attr_to_tb_attr {    # \@colors ($attr)
  my $attr = shift;

  state $colors = [
    TB_BLACK,
    TB_BLUE,
    TB_GREEN,
    TB_CYAN,
    TB_RED,
    TB_MAGENTA,
    TB_YELLOW,
    TB_WHITE,
  ];

  my $fg = $colors->[ $attr & 0x07 ];
  my $bg = $colors->[ ( $attr >> 4 ) & 0x07 ];

  $fg |= TB_BOLD  if $attr & 0x08;
  $fg |= TB_BLINK if $attr & 0x80;

  return [ $fg, $bg ];
} #/ sub _bios_attr_to_tb_attr

sub _tb_event_to_char_code {    # $charCode ($event)
  my $event = shift;

  state $CP437 = {
    map { $CP437_TO_UTF8[$_] => $_ } (0..255)
  };

  my $cp = $event->ch;

  # Support the official Unicode values instead only the Termius equivalents
  return 0x10 if $cp == ord "\x{25ba}";
  return 0x11 if $cp == ord "\x{25c4}";

  return $CP437->{$cp}
    if $cp && exists $CP437->{$cp};

  my $key = $event->key;

  return $key
    if $key <= 0x1f || $key == 0x7f;

  return 0;
}

sub _build_tb_to_tv_key_map {    # \%map ()
  my %tb_to_tv;

  my $id;
  while (my ($tv_key, $tb_key) = each %TV_TO_TB) {
    my ($mod, $key, $ch) = @$tb_key;

    # Default: first mapping wins.
    # This avoids accidental replacement caused by hash iteration order.
    $id = join(':', ($mod, $key, $ch));
    $tb_to_tv{$id} = $tv_key
      unless exists $tb_to_tv{$id};
  }

  # VT control-code collisions.
  #
  # VT stream     TV keys                 Preferred
  # ------------------------------------------------
  # 0x08          Ctrl-H, Ctrl-Back       Ctrl-Back
  # 0x09          Ctrl-I, Tab             Tab
  # 0x0A          Ctrl-J, Ctrl-Enter      Ctrl-Enter
  # 0x0D          Ctrl-M, Enter           Enter
  $tb_to_tv{ join(':', TB_MOD_CTRL, TB_KEY_BACKSPACE, 0) }
    = kbCtrlBack();
  $tb_to_tv{ join(':', TB_MOD_CTRL, TB_KEY_TAB, 0) }
    = kbTab();
  $tb_to_tv{ join(':', TB_MOD_CTRL, TB_KEY_CTRL_J, 0) }
    = kbCtrlEnter();
  $tb_to_tv{ join(':', TB_MOD_CTRL, TB_KEY_ENTER, 0) }
    = kbEnter();

  return \%tb_to_tv;
}

sub _tb_event_to_key_code {    # $keyCode ($event)
  my $event = shift;

  state $TB_TO_TV = _build_tb_to_tv_key_map();

  my $mod = $event->mod;
  my $key = $event->key;
  my $ch  = $event->ch;

  # Keep only keyboard modifier bits relevant for the key mapping.
  $mod &= TB_MOD_ALT | TB_MOD_CTRL | TB_MOD_SHIFT;

  my $id = join(':', ($mod, $key, $ch));
  return $TB_TO_TV->{$id}
    if exists $TB_TO_TV->{$id};

  return kbNoKey();
}

1;
