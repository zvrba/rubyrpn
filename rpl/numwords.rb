#
# Implementation of arithmetic words for numbers and matrices.
#

module RPL
  class Words
    @@numbers_dict = proc {
      defop("+",   [Numeric, Numeric]) { |a,b| a+b }
      defop("-",   [Numeric, Numeric]) { |a,b| a-b }
      defop("*",   [Numeric, Numeric]) { |a,b| a*b }
      defop("/",   [Numeric, Numeric]) { |a,b| a/b }
      defop("pow", [Numeric, Numeric]) { |a,b| a**b }

      defop("<",  [Numeric, Numeric]) { |a,b| a<b }
      defop("<=", [Numeric, Numeric]) { |a,b| a<=b }
      defop(">",  [Numeric, Numeric]) { |a,b| a>b }
      defop(">=", [Numeric, Numeric]) { |a,b| a>=b }
      defop("<>", [Numeric, Numeric]) { |a,b| a!=b }
      defop("=",  [Numeric, Numeric]) { |a,b| a==b }
        
      defop("neg", [Numeric]) { |x| -x }
      defop("abs", [Numeric]) { |x| x.abs }

      Math.singleton_methods.each { |m_name|
        method = Math.method m_name
        arity  = method.arity
        case arity
          when 1
          defop(m_name.to_s, [Numeric]*arity) { |a| method.call(a) }

          when 2
          defop(m_name.to_s, [Numeric]*arity) { |a,b| method.call(a,b) }
        end
      }

      # Can't handle variadic log -- register it as unary function
      defop("log", [Numeric]) { |x| Math.log(x) }

      defop("PI", []) { Math::PI }
      defop("E", [])  { Math::E }
    }
  end
end

