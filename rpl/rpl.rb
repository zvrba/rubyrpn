# A file to include everything.

require_relative 'syntax' # Parslet generates many warnings
$VERBOSE=true
require_relative 'helpers'
require_relative 'sequencer'
require_relative 'numwords'

module RPL
  class Words
    def Words.register(rpl)
      rpl.instance_exec &@@numbers_dict
    end
  end
end