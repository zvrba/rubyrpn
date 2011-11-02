module RPL

  # The main interpreter class.
  class Sequencer
    attr_reader :stack

    # No arguments -- creates a "clean slate" interpreter.
    def initialize
      @parser = Parser.new
      @walker = Walker.new
      @stack = []
      @vars = {}
      @ops = {}
      @default_formatter = proc { |o| o.inspect }
    end

    #
    # Compile a complete line and return a list of execution tokens (XTs).
    # Returns error string on failure.
    #
    def compile(line)
      @walker.apply(@parser.parse line)
    rescue ExecutionFailure
      "EXECUTION ERROR: #{$!}"
    rescue Parslet::ParseFailed
      "PARSE ERROR: #{$!}"
    end

    #
    # Execute a single XT or a list of XTs.  Returns error string on failure,
    # otherwise an unspecified (non-string) type.
    #
    def xt(tokens)
      tokens = [tokens] unless tokens.respond_to? :each
      tokens.each { |token|
        if token.respond_to? :xt then token.xt self else @stack << token end
      }
      return nil
    rescue ExecutionFailure
      return "EXECUTION ERROR: #{$!}"
    rescue Math::DomainError
      return "DOMAIN ERROR: #{$!}"
    end

    #
    # Return an array of strings representing stack items.  formats is a hash
    # that maps a class type (e.g. Integer) to a proc that produces a string
    # from its single argument; if the value is not present, #inspect is called.
    #
    def format_stack(formats)
      @stack.collect do |obj|
        formatter = formats[obj.class] || @default_formatter
        formatter.call(obj)
      end
    end

    # Return a definition associated with the given symbol.
    def symdef(symbol)
      return symbol.execute? ? @ops[symbol.name] : @vars[symbol.name]
    end

    #
    # Define a variable with the given name and value.  If value is nil, it is
    # popped from the stack.
    def defvar(symbol, v)
      RPL.fail(symbol, "cannot define variable -- empty stack") unless
        (v ||= @stack.pop)
      @vars[symbol.name] = v
    end

    #
    # Define an operation with the given name and parameters.  If parameters
    # is nil, anything is accepted.  Returns true if the overload was added,
    # false if it was replaced.
    #
    def defop(name, types, &code)
      @ops[name] = [] unless @ops[name]
      e = @ops[name]
      i = e.find_index { |o| types == o.types } || e.length
      r = i == e.length
      e[i] = Operator.new(types, code)
      return r
    end


  end

end     
