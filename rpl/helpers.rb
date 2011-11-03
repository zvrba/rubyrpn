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

  #
  # Raise ExecutionFailure with an appropriatelly formatted error message.
  # The error message consists of two parts: a cause (command/input string
  # that causet the error) and a message which explains the condition in more
  # detail.
  #
  def RPL.fail(cause, message)
    raise ExecutionFailure, "#{message} -- #{cause.to_s}"
  end

  #
  # A symbol can denote either a read/write from a variable (@/! prefix), or
  # an executable command (no prefix).
  #
  class Symbol
    def initialize(name)
      @name = name
    end
    
    def name ;        if execute? then @name else @name[1..-1] end end
    def to_s ;        name end

    def xt(rpl)
      if execute?
        d = rpl.symdef(self)
        raise "INTERNAL ERROR" unless d.kind_of? Array

        i = d.find_index { |o| o.matches? rpl.stack }
        RPL.fail(name, "cannot find overload") unless i

        d[i].xt rpl
      elsif write?
        rpl.defvar(self)
      else
        d = rpl.symdef(self) or RPL.fail(name, "undefined name")
        rpl.xt(d)
      end
    end

    def read? ;       @name[0] == "@" end
    def write? ;      @name[0] == "!"  end
    def execute? ;    !(read? || write?) end
  end

  #
  # An operator associates argument types with some code.
  #
  class Operator
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
    # the result (which may be nil, in which case no elements are created).
    def xt(rpl)
      if @types.nil?
        @code.call(rpl.stack)
      elsif @types.empty?
        rpl.stack << @code.call
      else
        v = @code.call(*rpl.stack[-@types.length .. -1])
        rpl.stack[-@types.length .. -1] = *v
      end
    end
  end

end
