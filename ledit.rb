#
# Line-oriented interface for RPN calculator.
#

require './rpl/syntax' # Parslet generates many warnings
$VERBOSE=true
require './rpl/helpers'
require './rpl/sequencer'

module RPL
  module Arithmetic
    def Arithmetic.extend_object(rpl)
      rpl.defop("+", [Numeric, Numeric]) { |a,b| a+b }
      rpl.defop("-", [Numeric, Numeric]) { |a,b| a-b }
      rpl.defop("*", [Numeric, Numeric]) { |a,b| a*b }
      rpl.defop("/", [Numeric, Numeric]) { |a,b| a/b }

      rpl.defop("neg", [Numeric]) { |x| -x }
      rpl.defop("abs", [Numeric]) { |x| x.abs }
    end
  end
end

class Ledit
  def initialize
    @sequencer = RPL::Sequencer.new
    @formats   = {}
    @lasterr   = nil
    
    @sequencer.extend(RPL::Arithmetic)
  end

  def main
    while (line = prompt)
      if (String === (xt = @sequencer.compile(line)))
        @lasterr = xt
        next
      end
      if (String === (xt = @sequencer.xt(xt)))
        @lasterr = xt
        next
      end
    end
  end

  def prompt
    if @lasterr
      STDERR.puts @lasterr
      @lasterr = nil
    else
      formatted_stack = @sequencer.format_stack @formats
      if formatted_stack.empty?
        puts "EMPTY STACK"
      else
        formatted_stack.each.with_index do |item, i|
          puts sprintf("%03d: %s", formatted_stack.length-i, item)
        end
      end
    end
    print "\nRPN> "
    gets.chomp!
  end

end

if $0 == __FILE__ then
  Ledit.new.main
end
