# require_relative 'syntax'

# The main interpreter class.
class RPLSequencer
  def initialize
    @parser = RPLSyntax.new
    @walker = RPLAST.new
    @stack = []
    @vars = {}
    @ops = {}
    @protected_opnames = []
  end

  def interpret(input_line)
    parsed_tree = parser.parse(input_line.chomp)
    walker.apply(parsed_tree).each { |item| do_item item }
  rescue Parslet::ParseFailed
    stack << "PARSE ERROR: $!"
  rescue RPLException
    stack << "ERROR: $!"
  end

private

  def do_item(item)
    if item.instance_of? RPLIdentifier then
      do_var item
    else
      do_value item
    end
  end

  def do_var(item)
    rpl_fail item, "variables not yet implemented"
  end

  def do_value(item)
    stack << item
  end
end

