AC_DEFUN([INZ_CHECK_GEMS],[
    AC_MSG_CHECKING([whether we've got all required gems])
    result=$($RUBY - $1 <<'    eof' 2>&1
      puts(ARGV.select do |gem|
        begin
          require gem
          false
        rescue LoadError
          true
        end
      end .join ' ')
    eof
    )
    if test x = "x$result"; then
      AC_MSG_RESULT([yes])
    else
      AC_MSG_RESULT([no])
      AC_MSG_ERROR([cannot find $result])
    fi
])
