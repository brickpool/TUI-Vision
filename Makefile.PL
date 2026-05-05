use 5.008;
use strict;
use warnings;

use ExtUtils::MakeMaker 6.64;

WriteMakefile(
  NAME              => 'TUI::Vision',
  AUTHOR            => 'J. Schneider',
  VERSION_FROM      => 'lib/TUI/Vision.pm',
  ABSTRACT          => 'Perl TUI Framework (Turbo Vision 2.0 Port)',
  LICENSE           => 'mit',
  MIN_PERL_VERSION  => '5.010',
  EXE_FILES         => ['bin/overview.pl'],

  CONFIGURE_REQUIRES  => {
    'ExtUtils::MakeMaker' => 6.64,
  },

  PREREQ_PM => {
    'autodie::Scope::Guard' => 0,
    'Carp'                  => 1.01,
    'Class::Struct'         => 0,
    'Devel::StrictMode'     => 0.003,
    'Encode'                => 0,
    'Importer'              => 0.026,
    'Import::Into'          => 1.002005,
    'List::Util'            => 1.33,
    'Module::Loaded'        => 0,
    'Params::Check'         => 0,
    'Scalar::Util'          => 1.36,
    'UNIVERSAL::Object'     => 0.17,
    'Win32'                 => 0.59,
    'Win32API::File'        => 0.1101,
    'Win32::API'            => 0.84,
    'Win32::Console'        => '0.10',
  },

  TEST_REQUIRES => {
    'Test::Exception' => 0.43,
    'Test::More'      => 0.95,
  },

  $^O eq 'MSWin32' ? (
    dist => {
        TARFLAGS => '-cvzf',
        COMPRESS => 'perl -MExtUtils::Command -e test_f',
        POSTOP   => 'perl -MExtUtils::Command -e mv $(DISTVNAME).tar '
        . '$(DISTVNAME).tar$(SUFFIX)'
    },
  ) : (
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },      
  ),
  test  => { TESTS => 't/*.t t/*/*.t' },
  clean => { FILES => 'TUI-Vision-*'  },

  META_MERGE => {
    'meta-spec' => { version => 2 },

    resources => {
      repository  => {
        type => 'git',
        url  => 'https://github.com/brickpool/TUI-Vision.git',
        web  => 'https://github.com/brickpool/TUI-Vision',
      },
      bugtracker  => { web => 'https://github.com/brickpool/TUI-Vision/issues' },
      homepage    => 'http://brickpool.de',
    },

    provides => {
        'TUI::Vision' 
            => { file => 'lib/TUI/Vision.pm', version => '2.0.0' },
        'TUI::App' 
            => { file => 'lib/TUI/App.pm', version => '2.0.0' },
        'TUI::Dialogs'
            => { file => 'lib/TUI/Dialogs.pm', version => '2.0.0' },
        'TUI::Drivers'
            => { file => 'lib/TUI/Drivers.pm', version => '2.0.0' },
        'TUI::Gadgets'
            => { file => 'lib/TUI/Gadgets.pm', version => '2.0.0' },
        'TUI::Memory'
            => { file => 'lib/TUI/Memory.pm', version => '2.0.0' },
        'TUI::MsgBox'
            => { file => 'lib/TUI/MsgBox.pm', version => '2.0.0' },
        'TUI::Objects' 
            => { file => 'lib/TUI/Objects.pm', version => '2.0.0' },
        'TUI::StdDlg'
            => { file => 'lib/TUI/StdDlg.pm', version => '2.0.0' },
        'TUI::TextView'
            => { file => 'lib/TUI/TextView.pm', version => '2.0.0' },
        'TUI::Validate'
            => { file => 'lib/TUI/Validate.pm', version => '2.0.0' },
        'TUI::Views'
            => { file => 'lib/TUI/Views.pm', version => '2.0.0' },
        'TUI::toolkit'
            => { file => 'lib/TUI/toolkit.pm', version => '2.0.0' },
    },

  },
);
