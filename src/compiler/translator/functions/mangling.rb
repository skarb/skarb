class Translator
  module Functions
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
        def Translator.mangle(name, class_name, args_types)
          sname = name.to_s
          SpecialCharsConversion.each_pair do |char, subst|
            sname.gsub! char, subst
          end
          [class_name.to_s, sname, *args_types].join('_').to_sym
        end
    end
  end
end