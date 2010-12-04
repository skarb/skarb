public_headers=object.h helpers.h fixnum.h float.h types.h
nodist_rubycinclude_HEADERS=rubyc.h
lib_LTLIBRARIES=librubyc.la
librubyc_la_SOURCES=$(public_headers) fixnum.c xalloc.c xalloc.h helpers.c \
                    float.c object.c
rubyc.h: $(public_headers)
	cat $^ |grep -v '#include "object.h"'> $@

clean-local:
	-rm -f rubyc.h
