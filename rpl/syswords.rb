#
# Implementation of system words -- stack manipulation, etc.
#

module RPL
  class Words
    @@stack_dict = proc {
      defop("drop",  [Object]*1) { |x|     nil }
      defop("dup",   [Object]*1) { |x|     [x,x] }
      defop("over",  [Object]*2) { |x,y|   [x,y,x] }
      defop("swap",  [Object]*2) { |x,y|   [y,x] }
      defop("rot",   [Object]*3) { |x,y,z| [y,z,x] }
      defop("unrot", [Object]*3) { |x,y,z| [z,x,y] }
      defop("clear", nil)        { |stack| stack.clear }
    }

  end
end
