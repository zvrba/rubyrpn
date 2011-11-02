#
# Implementation of arithmetic words for numbers and matrices.
#

module RPL
  class Words
    @@arithmetic = proc {
      defop("+", [Numeric, Numeric]) { |a,b| a+b }
      defop("-", [Numeric, Numeric]) { |a,b| a-b }
      defop("*", [Numeric, Numeric]) { |a,b| a*b }
      defop("/", [Numeric, Numeric]) { |a,b| a/b }
        
      defop("neg", [Numeric]) { |x| -x }
      defop("abs", [Numeric]) { |x| x.abs }
    }
  end
end

