#
# Implementation of arithmetic words for numbers and matrices.
#

module RPL
  class Words
    def Words.register_numbers_dict rpl
      rpl.instance_exec do
        # Constants
        defop("PI", []) { Math::PI }
        defop("E", [])  { Math::E }

        # Binary ops
        defop("+",   [Numeric, Numeric]) { |a,b| a+b }
        defop("-",   [Numeric, Numeric]) { |a,b| a-b }
        defop("*",   [Numeric, Numeric]) { |a,b| a*b }
        defop("/",   [Numeric, Numeric]) { |a,b| a/b }
        defop("pow", [Numeric, Numeric]) { |a,b| a**b }
        defop("mod", [Numeric, Numeric]) { |a,b| a%b }

        # Relational ops
        defop("<",  [Numeric, Numeric]) { |a,b| a<b }
        defop("<=", [Numeric, Numeric]) { |a,b| a<=b }
        defop(">",  [Numeric, Numeric]) { |a,b| a>b }
        defop(">=", [Numeric, Numeric]) { |a,b| a>=b }
        defop("<>", [Numeric, Numeric]) { |a,b| a!=b }
        defop("==",  [Numeric, Numeric]) { |a,b| a==b }
        
        # Unary ops
        defop("neg",   [Numeric]) { |x| -x }
        defop("abs",   [Numeric]) { |x| x.abs }
        defop("inv",   [Numeric]) { |x| 1.0 / x }
        defop("sq",    [Numeric]) { |x| x*x }
        defop("floor", [Numeric]) { |x| x.floor }
        defop("ceil",  [Numeric]) { |x| x.ceil }
        defop("trunc", [Numeric]) { |x| x.truncate }
        defop("r>d",   [Numeric]) { |x| x*180 / Math::PI }
        defop("d>r",   [Numeric]) { |x| x*Math::PI / 180 }

        # Import transcedental functions from Math
        Math.singleton_methods.each do |m_name|
          method = Math.method m_name
          arity  = method.arity
          case arity
          when -1, 1 # -1 covers variadic log method, default natural
            defop(m_name.to_s, [Numeric]) { |a| method.call(a) }

          when 2
            defop(m_name.to_s, [Numeric]*arity) { |a,b| method.call(a,b) }
          end
        end
      end
    end
  end
end

