# A file to include everything.

require_relative 'syntax' # Parslet generates many warnings
$VERBOSE=true
require_relative 'helpers'
require_relative 'sequencer'
require_relative 'syswords'
require_relative 'numwords'
require_relative 'bitwords'
require_relative 'lawords'


module RPL
  class Words
    def Words.register(rpl)
      Words.register_numbers_dict   rpl
      Words.register_matrix_dict    rpl
      Words.register_stack_dict     rpl
      Words.register_bit_dict       rpl
      Words.register_misc_dict      rpl
    end
  end
end
