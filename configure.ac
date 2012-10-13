AC_PREREQ([2.65])
AC_INIT([rubyc], [snapshot])
AM_INIT_AUTOMAKE([1.10 foreign color-tests])
AC_DISABLE_STATIC

# Tests related to Ruby
AC_CHECK_PROGS(RUBY, [ruby])
if test x = "x$RUBY" -o true != "`$RUBY -e 'puts RUBY_VERSION>="1.9.2"'`"; then
	AC_MSG_ERROR([cannot find Ruby >= 1.9.2])
fi
INZ_CHECK_GEMS([rspec sexp_processor ruby_parser simplecov])

# Tests related to C
AC_PROG_CC_C99
AC_PROG_LIBTOOL
AC_TYPE_SIZE_T
AC_TYPE_UINT32_T
AC_FUNC_MALLOC
AC_FUNC_REALLOC

AC_CHECK_FUNCS([floor], [AC_SUBST(MATH_LIBS, [""])],
               AC_CHECK_LIB([m], [floor], [AC_SUBST(MATH_LIBS, ["-lm"])],
                            AC_MSG_ERROR([cannot find floor])))

PKG_CHECK_MODULES([GLib], [glib-2.0 >= 2.24.1])

# Other tests
AC_PROG_AWK
AC_CHECK_PROGS([GPERF], [gperf])
if test -z "$GPERF"; then
	AC_MSG_ERROR([cannot find GNU gperf])
fi
AC_CHECK_PROGS(RUBBER, [rubber])
if test -z "$RUBBER"; then
	AC_CHECK_PROGS(PDFLATEX, [pdflatex])
	if test -z "$PDFLATEX"; then
		AC_MSG_NOTICE([cannot find neither rubber nor pdflatex])
	else
		AC_SUBST(LATEXC, ["\$(top_srcdir)/scripts/twice.sh $PDFLATEX"])
	fi
else
	AC_SUBST(LATEXC, ["$RUBBER -d"])
fi
AM_CONDITIONAL([HAVE_LATEXC], [test x != "x$LATEXC"])
AC_CHECK_PROGS(PERL, [perl])
if test -z "$PERL"; then
	AC_MSG_ERROR([cannot find Perl])
fi
AC_SUBST([rubycincludedir], ["$includedir/rubyc"])

# Download, verify and configure libgc
AC_MSG_NOTICE([=== configuring libgc ===])
if test ! -f gc-7.1.tar.gz; then
	wget http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/gc-7.1.tar.gz
fi
gc_sha1sum=e84cba5d18f4ea5ed4e5fd3f1dc6a46bc190ff6f
if test "x`sha1sum gc-7.1.tar.gz | cut -c-40`" != "x$gc_sha1sum"; then
	AC_MSG_ERROR([gc-7.1.tar.gz is invalid, please remove it])
fi
tar -xf gc-7.1.tar.gz && cd gc-7.1 && \
	./configure --disable-threads --disable-cplusplus --disable-shared \
	CFLAGS="$CFLAGS -fPIC" && \
	cd .. || AC_MSG_ERROR([failed to configure libgc])
AC_MSG_NOTICE([=== done configuring libgc ===])

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