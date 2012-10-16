public_headers=object.h class.h helpers.h fixnum.h float.h types.h xalloc.h \
               stringclass.h nil.h array.h hash.h true.h false.h blocks.h \
	       method_cache.h
nodist_skarbinclude_HEADERS=skarb.h
lib_LTLIBRARIES=libskarb.la
libskarb_la_SOURCES=$(public_headers) fixnum.c xalloc.c helpers.c \
                    float.c object.c stringclass.c nil.c array.c hash.c class.c \
		    false.c true.c blocks.c method_cache.c
libskarb_la_CFLAGS=-I$(top_builddir)/gc-7.1/include -Wall -Werror $(GLib_CFLAGS)
libskarb_la_LIBADD=$(top_builddir)/gc-7.1/libgc.la $(GLib_LIBS) $(MATH_LIBS)

$(top_builddir)/gc-7.1/libgc.la:
	make libgc.la -C $(top_builddir)/gc-7.1

skarb.h: $(public_headers)
	cat $^ | grep -v '#include ".*"' > $@

clean-local:
	-rm -f skarb.h
