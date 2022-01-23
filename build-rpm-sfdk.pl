#!/usr/bin/perl
use strict;
use warnings;

my $SFDK = "$ENV{HOME}/SailfishOS/bin/sfdk";

my $TARGET = "SailfishOS-4.3.0.12-aarch64";

my $SPEC = "RPM/SPEC/python2-pyqt5.spec";
my $SIP_PATCH_GLOB = "build-sip-patches/*";

my @PKG_DEPS = qw(
  python
  python-devel
);

my @RPM_DEPS = qw(
  rpmbuild/RPMS/aarch64/python2-sip-4.19.4-sf0.1.aarch64.rpm
);

my @PKG_TOOLS = qw(
  git
  vim-enhanced
);

sub getPkgInfo();
sub sfdkCmd(@);
sub run(@);

sub main(@){
  run "$SFDK config --push target $TARGET";

  for my $pkg(@PKG_TOOLS, @PKG_DEPS){
    run "$SFDK tools package-install $TARGET $pkg";
  }

  print "NOTE: MUST BUILD python-sip RPM FIRST\n";
  for my $rpmFile(@RPM_DEPS){
    run "$SFDK tools package-install $TARGET $rpmFile";
  }

  my $pkg = getPkgInfo();
  my $rpmName = "$$pkg{name}-$$pkg{version}-$$pkg{release}.$$pkg{arch}";

  sfdkCmd "python", "configure.py";

  for my $patch(glob $SIP_PATCH_GLOB){
    next if not -e $patch;

    my $targetFile = $patch;
    $targetFile =~ s/^.*\///;
    $targetFile =~ s/%/\//g;
    if(not -f $targetFile){
      die "ERROR: $targetFile for patch $patch does not exist\n";
    }
    sfdkCmd "patch -N -i $patch $targetFile";
  }

  sfdkCmd "make", "-j8";
  sfdkCmd "make", "INSTALL_ROOT=/home/mersdk/rpmbuild/BUILDROOT/$rpmName", "install";
  sfdkCmd "rpmbuild", "-bb", $SPEC;
  sfdkCmd "cp", "/home/mersdk/rpmbuild/RPMS/$$pkg{arch}/$rpmName.rpm", ".";
}

sub getPkgInfo(){
  my $out = `cat $SPEC 2>/dev/null`;
  my $pkg = {};
  $$pkg{name}    = $1 if $out =~ /^Name:      \s* (\S+)$/mx;
  $$pkg{arch}    = $1 if $out =~ /^BuildArch: \s* (\S+)$/mx;
  $$pkg{version} = $1 if $out =~ /^Version:   \s* (\S+)$/mx;
  $$pkg{release} = $1 if $out =~ /^Release:   \s* (\S+)$/mx;

  for my $key(qw(name arch version release)){
    die "ERROR: could not parse $key in $SPEC\n" if not defined $$pkg{$key};
  }

  return $pkg;
}

sub sfdkCmd(@){
  run($SFDK, "build-shell", @_);
}

sub run(@){
  print "@_\n";
  system @_;
}

&main(@ARGV);
