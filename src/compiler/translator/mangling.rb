module Mangling
  SpecialCharsConversion = {
    '+'  => '__PLUS__',
    '-'  => '__MINUS__',
    '*'  => '__MUL__',
    '/'  => '__DIV__',
    '='  => '__EQ__',
    '[]' => '__INDEX__',
    '?'  => '__QMARK' }

    # Returns a mangled function name for a given name, class, and
    # an array of arguments' types.
    def mangle_function_name(name, version, class_name, args_types)
      sname = name.to_s
      SpecialCharsConversion.each_pair do |char, subst|
        sname.gsub! char, subst
      end
      if version == 0
        [class_name.to_s, sname, *args_types].join('_').to_sym
      else
        [class_name.to_s, sname, version, *args_types].join('_').to_sym
      end
    end

    # Returns a name for a function representing class method.
    def mangle_defs_name(name)
      ('s_'+name.to_s).to_sym
    end

    # Returns a name for a global structure containing class variables.
    def mangle_cvars_struct_name(name)
      ('s_'+name.to_s).to_sym
    end

    # Returns a name for instance of a global structure containing class
    # variables.
    def mangle_cvars_struct_var_name(name)
      ('vs_'+name.to_s).to_sym
    end

    # Returns a name for a constant.
    def mangle_const_name(name)
      ('c_'+name.to_s).to_sym
    end

    # Returns a name for a global variable.
    def mangle_gvar_name(name)
      sname = name.to_s
      ('g_'+sname[1..sname.length-1]).to_sym
    end

    # Returns a name for an instance variable.
    def mangle_ivar_name(name)
      sname = name.to_s
      (sname[1..sname.length-1]).to_sym
    end

    # Returns a name for an instance variable.
    def mangle_cvar_name(name)
      sname = name.to_s
      (sname[2..sname.length-1]).to_sym
    end

    # Returns given name with underscores escaped.
    def escape_name(name)
      name.to_s.gsub('_', '__').to_sym 
    end

    alias :mangle_lvar_name :escape_name
end
