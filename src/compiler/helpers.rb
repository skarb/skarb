# Includes some helper methods to be used all around the project.
module Helpers
  # Prints a given message and exits.
  def die(msg)
    puts msg
    exit 1
  end
end
