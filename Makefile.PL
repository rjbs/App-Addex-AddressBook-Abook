use strict;
use warnings;

use inc::Module::Install;

name          ('App-Addex-AddressBook-Abook');
author        ('Ricardo Signes <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/App/Addex/AddressBook/Abook.pm');

requires('App::Addex'          => 0.007); # the EmailAddress module
requires('Config::INI::Reader' => 0.001); # already required by Addex
requires('File::HomeDir'       => 0    ); # minimum unknown
requires('File::Spec'          => 0    ); # minimum unknown

WriteAll();
