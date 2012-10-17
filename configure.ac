AC_PREREQ([2.65])
AC_INIT([skarb], [snapshot], [https://github.com/skarb/skarb/issues])
AM_INIT_AUTOMAKE([1.10 foreign color-tests])
AC_DISABLE_STATIC

# Tests related to Ruby
AC_CHECK_PROGS(RUBY, [ruby])
if test x = "x$RUBY" -o true != "`$RUBY -e 'puts RUBY_VERSION>="1.9.2"'`"; then
  AC_MSG_ERROR([cannot find Ruby >= 1.9.2])
fi
INZ_CHECK_GEMS([rspec ruby_parser simplecov])

# Tests related to C
AC_PROG_CC_C99
AC_PROG_LIBTOOL

AC_SEARCH_LIBS([floor], [m], [], [
  AC_MSG_ERROR([unable to find the floor function])])

PKG_CHECK_MODULES([GLib], [glib-2.0 >= 2.24.1])
PKG_CHECK_MODULES([BDWGC], [bdw-gc >= 7.1])

# Other tests
AC_CHECK_PROGS([GPERF], [gperf])
if test -z "$GPERF"; then
  AC_MSG_ERROR([cannot find GNU gperf])
fi

AC_SUBST([skarbincludedir], ["$includedir/skarb"])

AC_CONFIG_FILES([
                 Makefile
                 src/Makefile
                 src/compiler/emitter/Makefile
                 src/compiler/translator/Makefile
                 src/compiler/optimizations/Makefile
                 src/compiler/optimizations/connection_graph_builder/Makefile
                 src/compiler/Makefile
                 src/stdlib/Makefile
                 test/Makefile
                 test/functional/Makefile
                 test/functional/ui/Makefile
                 test/performance/Makefile
                 test/unit/Makefile
                 ])
AC_OUTPUT
