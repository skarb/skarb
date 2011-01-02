class Translator
  module Functions
    module Mangling
      SpecialCharsConversion = {
        '_'  => '__',
        '+'  => '__PLUS__',
        '-'  => '__MINUS__',
        '*'  => '__MUL__',
        '/'  => '__DIV__',
        '='  => '__EQ__',
        '[]' => '__INDEX__',
        '?'  => '__QMARK' }

        # Returns a mangled function name for a given name, class, and
        # an array of arguments' types.
        def Translator.mangle(name, version, class_name, args_types)
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
    end
  end
end
