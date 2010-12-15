public_headers=object.h helpers.h fixnum.h float.h types.h xalloc.h \
               stringclass.h nil.h
nodist_rubycinclude_HEADERS=rubyc.h
lib_LTLIBRARIES=librubyc.la
librubyc_la_SOURCES=$(public_headers) fixnum.c xalloc.c helpers.c \
                    float.c object.c stringclass.c nil.c
librubyc_la_CFLAGS=-I$(top_builddir)/gc-7.1/include -Wall -Werror $(GLib_CFLAGS)
librubyc_la_LIBADD=$(top_builddir)/gc-7.1/libgc.la $(GLib_LIBS)

$(top_builddir)/gc-7.1/libgc.la:
	make libgc.la -C $(top_builddir)/gc-7.1

rubyc.h: $(public_headers)
	cat $^ |grep -v '#include "object.h"'> $@

clean-local:
	-rm -f rubyc.h
