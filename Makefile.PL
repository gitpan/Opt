use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'  => 'Opt',
    'VERSION_FROM' => 'Opt.pm', # finds $VERSION
    'PREREQ_PM' => { },
);
