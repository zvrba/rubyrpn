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
        defop("sto", [Array]) { |varlist|
          RPL.fail("!", "stack underflow") unless @stack.length >= varlist.length
          varlist.each { |name|
            RPL.fail("!", "invalid type") unless name.is_a? Name
            RPL.fail("!", "cannot redefine word") if @names[name.name].kind_of? Word
          }
          varlist.each { |name|
            @names[name.name] = @stack.pop
          }
          nil
        }

        defop("purge", [Array]) { |varlist|
          # Do it transactionally -- don't do anything unless everything succeeds.
          varlist.each { |name|
            RPL.fail("purge", "undefined name #{name}") unless @names[name]
            RPL.fail("purge", "cannot purge command #{name}") if @names[name].kind_of? Word
          }
          x.each { |name| @names.delete name }
          nil
        }

        defop("~", [Vector,Numeric,Array]) { |v,n,a|
          v.each { |e|
            @stack.push(e,n)
            xt(a)
            @stack.pop
          }
        }
      end
    end
  end
end
