#
# Implementation of system words -- stack manipulation, etc.
#

module RPL
  class Words
    def Words.register_stack_dict rpl
      rpl.instance_exec do

        defop("drop",  [Object]*1) { |x|     nil }
        defop("dup",   [Object]*1) { |x|     [x,x] }
        defop("over",  [Object]*2) { |x,y|   [x,y,x] }
        defop("swap",  [Object]*2) { |x,y|   [y,x] }
        defop("rot",   [Object]*3) { |x,y,z| [y,z,x] }
        defop("unrot", [Object]*3) { |x,y,z| [z,x,y] }
        defop("clear", nil)        { |stack| stack.clear }

      end
    end

    def Words.register_misc_dict rpl
      rpl.instance_exec do

        # NB! Not transactional!
        defop("!", [Array]) { |varlist|
          RPL.fail("!", "stack underflow") unless @stack.length >= varlist.length
          varlist.reverse.each { |name| defvar(name, @stack.pop) }
          nil
        }

        # NB! Not transactional!
        defop("purge", [Array]) { |varlist|
          varlist.each { |name| rmvar name }
          nil
        }

        # "thread"
        defop("~", [Vector,Numeric,Array]) { |v,n,a|
          v.map { |e|
            @stack.push(e,n)
            xt(a)
            @stack.pop
          }
        }

      end
    end
  end
end
