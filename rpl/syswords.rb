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

        defop("!", [Array]) { |varlist|            # NB! NOT TRANSACTIONAL!  
          RPL.fail("!", "stack underflow") unless
            @stack.length >= varlist.length
          varlist.reverse.each { |name| defvar(name, @stack.pop) }
          nil
        }

        defop("purge", [Array]) { |varlist|        # NB! NOT TRANSACTIONAL!
          varlist.each { |name| rmvar name }
          nil
        }

        # ~ as a mnemonic for "threading": returning an array prevents
        # elementwise splicing of vector elements into the stack.
        # NB! Most-specific (largest arity) overloads must come first!

        defop("~", [Vector,Vector,Array]) { |v1,v2,a|
          [Vector[ # #collect2 returns an array?!
                  *(v1.collect2(v2) { |e1,e2| @stack.push(e1,e2); xt(a); @stack.pop })
                 ]]
        }
        defop("~", [Vector,Numeric,Array]) { |v,n,a|
          [v.collect { |e| @stack.push(e,n); xt(a); @stack.pop }]
        }
        defop("~", [Numeric,Vector,Array]) { |n,v,a|
          [v.collect { |e| @stack.push(e,n); xt(a); @stack.pop }]
        }
        defop("~", [Vector,Array]) { |v,a|
          [v.collect { |e| @stack.push(e); xt(a); @stack.pop }]
        }

      end
    end
  end
end
