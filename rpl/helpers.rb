#
# This file defines small helper classes and methods.
#

module RPL

  # This is class is used by operators to report errors.  
  class ExecutionFailure < StandardError
    def initialize(message)
      super(message)
    end
  end

  # Raise ExecutionFailure with an appropriatelly formatted error message.
  # The error message consists of two parts: a cause (command/input string
  # that causet the error) and a message which explains the condition in more
  # detail.
  def RPL.fail(cause, message)
    raise ExecutionFailure, "#{message} -- #{cause.to_s}"
  end

  # A name is either:
  # read:: In which case, its value is fetched and executed
  # written:: When the first character is exclamation.
  class Name
    def initialize(name)
      @name = name
    end

    def name
      @name
    end

    def to_s
      "'#{@name}"
    end

    def xt(rpl)
      d = rpl.names[@name] || RPL.fail(@name, "undefined name")
      if d.respond_to? :xt then d.xt rpl else rpl.stack << d end
    end
  end

  # An overload associates a list of argument types with code.
  class Overload
    attr_reader :types, :code

    def initialize(t, c)
      @types = t
      @code = c
    end

    # Test whether the topmost stack elements match the operator's types.  The
    # test is performed by using #kind_of?, and the LAST item in the list is
    # matched against the TOP stack element.  Argument list given to
    # Sequencer::defop can have several formats:
    #
    # empty, i.e., +[]+:: The function doesn't take any arguments and returns
    #   a result
    # an array of parameter types, e.g., [Vector,Integer]:: The function takes
    #   Vector (as first argument; just below top of stack) and Integer (as
    #   second argument; top of stack)
    # nil:: The function receives the complete stack as the single argument.
    #   The TOS is the last element.
    def matches?(stack)
      return true if (@types.nil? || @types.empty?)
      d = @types.length
      (stack.length >= d) &&
        (stack[-d .. -1].map.with_index { |v,i| v.kind_of? @types[i] }.all?)
    end

    # Execute the associated code.  When the argument list is non-nil and non-empty,
    # the appropriate number of arguments are popped of the stack and replaced with
    # the result (which may be nil, in which case no elements are created).  The
    # arguments are popped off BEFORE the code is called, so it is possible to make
    # varargs commands.
    def xt(stack)
      if @types.nil?
        @code.call(stack)
      elsif @types.empty?
        stack << @code.call
      else
        v = @code.call(*stack.pop(@types.length))
        stack.push(*v)
      end
    end
  end

  # This is the object stored in the sequencer's dictionary.
  class Word
    def initialize(name)
      @name = name
      @overloads = []
    end

    def defop(types, code)
      i = @overloads.find_index { |o| o.types == types } || @overloads.length
      STDERR.puts "WARNING: redefining #{@name} for #{types}" if i < @overloads.length
      @overloads[i] = Overload.new(types, code)
    end

    def xt(rpl)
      i = @overloads.find_index { |o| o.matches? rpl.stack } ||
        RPL.fail(@name, "cannot find overload for stack arguments")
      @overloads[i].xt rpl.stack
    end
  end

end
