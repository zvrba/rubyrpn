# require_relative 'syntax'

# The main interpreter class.
class RPLSequencer

  # No arguments -- creates a "clean slate" interpreter.
  def initialize
    @parser = RPLSyntax.new
    @walker = RPLAST.new
    @stack = []
    @vars = {}
    @ops = {}
    @default_formatter = proc { |o| o.inspect }
  end

  # Interpret a complete line.  The input is currenlty ONLY line-based.
  def interpret(input_line)
    parsed_tree = @parser.parse(input_line.chomp)
    @walker.apply(parsed_tree).each { |item| do_item item }
  rescue Parslet::ParseFailed
    @stack << "PARSE ERROR: #{$!}"
  rescue RPLException
    @stack << "ERROR: #{$!}"
  end

  # Return an array of strings representing stack items.  formats is a hash
  # that maps a class type (e.g. Integer) to a proc that produces a string
  # from its single argument; if the value is not present, an inspect method
  # is called on the object.
  def format_stack(formats)
    @stack.collect do |obj|
      formatter = formats[obj.class] || @default_formatter
      formatter.call(obj)
    end
  end

  # Register an operation with the given name and parameters.  overload is an
  # array of parameter types that are matched against the stack types using
  # kind_of? (which means that superclasses can be used).  The rightmost type
  # in the array matches the TOP of the stack.
  def register_op(name, overload, &proc)
    @ops[name] = {:overloads => [], :procs => [] } unless @ops[name]
    entry      = @ops[name]
    overload_i = entry[:overloads].find_index overload
    status     = overload_i ? :replaced : :added
    overload_i = name_entry[:overloads].length unless overload_i

    op[:overloads][overload_i] = types
    op[:procs][overload_i]     = proc
    return status
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
    @stack << item
  end
end

