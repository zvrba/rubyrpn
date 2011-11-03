#
# Line-oriented interface for RPN calculator.
#

require './rpl/rpl'

class Ledit
  def initialize
    @sequencer = RPL::Sequencer.new
    RPL::Words.register @sequencer

    @formats   = {}
    @lasterr   = nil
  end

  def main
    while (line = prompt)
      begin
        xt = @sequencer.compile(line)
        @sequencer.xt xt
      rescue
        @lasterr = "#{$!.to_s} [#{$!.class}]"
      end
    end
  end

  def prompt
    if @lasterr
      STDERR.puts "ERROR: #{@lasterr}"
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
