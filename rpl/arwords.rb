#
# Implementation of arithmetic words for numbers and matrices.
#

module RPL
  class Words
    def Words.register_arithmetic(rpl)
      rpl.instance_exec do
        defop("+", [Numeric, Numeric]) { |a,b| a+b }
        defop("-", [Numeric, Numeric]) { |a,b| a-b }
        defop("*", [Numeric, Numeric]) { |a,b| a*b }
        defop("/", [Numeric, Numeric]) { |a,b| a/b }
        
        defop("neg", [Numeric]) { |x| -x }
        defop("abs", [Numeric]) { |x| x.abs }
      end
    end
  end
end

