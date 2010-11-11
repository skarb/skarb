AC_DEFUN([INZ_CHECK_GEMS],[
    AC_MSG_CHECKING([whether we've got all required gems])
    result=`$RUBY -e '
      ARGV.each { |f| begin; require f; rescue LoadError; puts(f); exit 1; end }
    ' $1 2>&1`
    if test x = "x$result"; then
      AC_MSG_RESULT([yes])
    else
      AC_MSG_RESULT([no])
      AC_MSG_ERROR([cannot find $result])
    fi
])
