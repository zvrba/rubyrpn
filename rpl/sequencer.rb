module RPL

  # The main interpreter class.
  class Sequencer
    attr_reader :stack, :names

    # No arguments -- creates a "clean slate" interpreter.
    def initialize
      @parser = Parser.new
      @walker = Walker.new
      @stack  = []
      @names  = {}
      self.wordsize = 0
    end

    #
    # Compile a complete line and return a list of execution tokens (XTs).
    # Returns error string on failure.
    #
    def compile(line)
      @walker.apply(@parser.parse line)
    end

    # Execute a single XT or a list of XTs.
    def xt(tokens)
      tokens = [tokens] unless tokens.respond_to? :each
      tokens.each { |token|
        if token.respond_to? :xt then token.xt self else @stack << token end
      }
    end

    # Get/set wordsize (affects binary ops!)

    def wordsize
      @wordsize
    end

    # When given 0, there is no limit to the number of retained bits.
    # (-1 acts as identity wrt 'bitand' in 2nd complement)
    def wordsize=(ws)
      RPL.fail("setws #{ws}", "wordsize must be >= 0") if ws < 0
      @wordsize = ws
      @wordmask = ws > 0 ? (1 << ws)-1 : -1
    end

private

    # Define an operation with the given name and parameters.
    def defop(name, types, &code)
      RPL.fail("defop #{name}", "invalid type") unless
        (name.is_a? String or name.nil?)
      @names[name] ||= Word.new(name)
      @names[name].defop(types, code)
    end

    # Make a variable definition
    def defvar(name, val)
      RPL.fail("defvar #{name}", "invalid type") unless name.is_a? Name
      RPL.fail("defvar #{name}", "can't redefine words") if @names[name.name].is_a? Word
      RPL.fail("defvar #{name}", "missing/invalid value") unless val
      @names[name.name] = val
    end

    # Remove a variable definition.
    def rmvar(name)
      RPL.fail("rmvar #{name}", "invalid type") unless name.is_a? Name
      RPL.fail("rmvar #{name}", "can't remove words") if @names[name.name].is_a? Word
      @names.delete name.name
    end

  end

end
