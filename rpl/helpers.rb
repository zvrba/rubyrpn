#
# This file defines small helper classes and methods.
#

module RPL

  # This is class is used by operators to report errors.  
  class ExecutionFailure < Exception
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
      if write?
        rpl.defvar(self)
      else
        d = rpl.symdef(name) or RPL.fail(name, "undefined name")
        rpl.xt(d)
      end
    end

    private

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
    # matched against the TOP stack element.
    def matches?(stack)
      d = @types.length
      (@types.length <= d) and
        (stack[-d .. -1].map.with_index { |v,i| v.kind_of? @types[i] }.all?)
    end

    def xt(rpl)
      @code.call(*@rpl.stack[-@types.length .. -1])
    end
  end

end
