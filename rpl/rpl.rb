# A file to include everything.

require_relative 'syntax' # Parslet generates many warnings
$VERBOSE=true
require_relative 'helpers'
require_relative 'sequencer'
require_relative 'arwords'

module RPL
  class Words
    def Words.register(rpl)
      Words.register_arithmetic rpl
    end
  end
end
