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
  # from its single argument; if the value is not present, #inspect is called.
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
  # Returns true if the overload was added, false if it was replaced.
  def register_op(name, overload, &proc)
    @ops[name] = {:overloads => [], :procs => [] } unless @ops[name]
    entry      = @ops[name]
    overload_i = entry[:overloads].find_index(overload) || entry[:overloads].length
    status     = overload_i == entry[:overloads].length

    entry[:overloads][overload_i] = overload
    entry[:procs][overload_i]     = proc
    return status
  end

private

  def find_overload_index(overloads)
    return overloads.find_index { |o| o.length <= @stack.length and match_overload(o) }
  end

  def match_overload(o)
    @stack[-o.length .. -1].map.with_index do |stack_item, index|
      stack_item.kind_of? o[index]
    end.all?
  end

  def do_item(item)
    if item.instance_of? RPLIdentifier then
      do_var item
    else
      do_value item
    end
  end

  def do_var(item)
    if item.execute?
      entry = @ops[item.name] or
        rpl_fail(item.name, "undefined operation")

      overload_i = find_overload_index(entry[:overloads]) or
        rpl_fail(item.name, "no overload found for given arguments")

      nargs  = entry[:overloads][overload_i].length
      retval = entry[:procs][overload_i].call(*@stack[-nargs .. -1])
      @stack[-nargs .. -1] = retval
    elsif item.read?
    elsif item.write?
    else
      fail "Internal error -- unknown variable mode"
    end
  end

  def do_value(item)
    @stack << item
  end

end

