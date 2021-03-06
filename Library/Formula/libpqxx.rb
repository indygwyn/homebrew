require 'formula'

class PostgresqlInstalled < Requirement
  def message; <<-EOS.undent
    PostgreSQL is required to install.

    You can install this with:
      brew install postgresql

    Or you can use an official installer from:
      http://www.postgresql.org/
    EOS
  end
  def satisfied?
    which 'pg_config'
  end
  def fatal?
    true
  end
end

class Libpqxx < Formula
  homepage 'http://pqxx.org/development/libpqxx/'
  url 'http://pqxx.org/download/software/libpqxx/libpqxx-4.0.tar.gz'
  sha1 '09e6301e610e7acddbec85f4803886fd6822b2e6'

  depends_on 'pkg-config' => :build
  depends_on PostgresqlInstalled.new

  # Patches borrowed from MacPorts. See:
  # https://trac.macports.org/ticket/33671
  # https://trac.macports.org/changeset/91294
  #
  # (1) Patched maketemporary to avoid an error message about improper use
  #     of the mktemp command; apparently maketemporary is designed to call
  #     mktemp in various ways, some of which may be improper, as it attempts
  #     to determine how to use it properly; we don't want to see those errors
  #     in the configure phase output.
  # (2) Patched splitconfig to avoid usage of "echo -n" which is not
  #     POSIX-compliant, thus causing incorrect output on Snow Leopard
  #     and later.
  # (3) Patched configure on darwin to fix incorrect assumption
  #     that true and false always live in /bin; on OS X they live in /usr/bin.
  def patches; DATA; end

  def install
    system "./configure", "--prefix=#{prefix}", "--enable-shared"
    system "make install"
  end
end

__END__
--- a/tools/maketemporary.orig	2009-07-04 00:38:30.000000000 -0500
+++ b/tools/maketemporary	2012-03-18 01:13:26.000000000 -0500
@@ -5,7 +5,7 @@
 TMPDIR="${TMPDIR:-/tmp}"
 export TMPDIR

-T="`mktemp`"
+T="`mktemp 2>/dev/null`"
 if test -z "$T" ; then
	T="`mktemp -t pqxx.XXXXXX`"
 fi

--- a/tools/splitconfig.orig	2009-07-04 00:38:30.000000000 -0500
+++ b/tools/splitconfig	2012-03-18 01:06:12.000000000 -0500
@@ -105,7 +105,7 @@
	esac
 }

-echo -n "Checking for usable grep -F or equivalent... "
+printf "Checking for usable grep -F or equivalent... "
 SAMPLEPAT="foo
 bar
 splat"
@@ -139,7 +139,7 @@
 for publication in $PUBLICATIONS ; do
	for factor in $FACTORS ; do
		CFGFILE="include/pqxx/config-${publication}-${factor}.h"
-		echo -n "Generating $CFGFILE: "
+		printf "Generating $CFGFILE: "
		ITEMS="`grep -w "${publication}" "$CFDB" | grep -w "${factor}" | cut -f 1 | grep -v '^$'`"
		if test -z "$ITEMS" ; then
			echo "no items--skipping"

--- a/configure.orig	2011-11-27 05:12:25.000000000 -0600
+++ b/configure	2012-03-18 01:09:08.000000000 -0500
@@ -15204,7 +15204,7 @@
 fi


- if /bin/true; then
+ if /usr/bin/true; then
   BUILD_REFERENCE_TRUE=
   BUILD_REFERENCE_FALSE='#'
 else
@@ -15290,7 +15290,7 @@
 fi


- if /bin/true; then
+ if /usr/bin/true; then
   BUILD_TUTORIAL_TRUE=
   BUILD_TUTORIAL_FALSE='#'
 else
@@ -15299,7 +15299,7 @@
 fi

 else
- if /bin/false; then
+ if /usr/bin/false; then
   BUILD_REFERENCE_TRUE=
   BUILD_REFERENCE_FALSE='#'
 else
@@ -15307,7 +15307,7 @@
   BUILD_REFERENCE_FALSE=
 fi

- if /bin/false; then
+ if /usr/bin/false; then
   BUILD_TUTORIAL_TRUE=
   BUILD_TUTORIAL_FALSE='#'
 else
