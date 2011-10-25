require 'syntax'

# The main interpreter class.
class RPLSequencer
  def initialize()
    @parser = RPLSyntax.new
    @walker = RPLAST.new
    @stack  = []
    @vars   = {}
    @ops    = {}
  end

  def do_value(value)
    stack << value
  end

  def do_operator(op)
    fail "UNIMPLEMENTED"
  end

  def do_input(line)
    parsed_tree = parser.parse(line.chomp!)
    raw_objects = walker.apply(parsed_tree)
  rescue RPLException
    $!.message
  end
end
