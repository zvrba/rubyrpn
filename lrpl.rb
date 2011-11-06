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
        oldstack = @sequencer.stack.clone
        xt = @sequencer.compile(line)
        @sequencer.xt xt
      rescue
        @lasterr = "#{$!.to_s} [#{$!.class}]"
        @sequencer.stack[0..-1] = oldstack
        #raise
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
        puts "--EMPTY STACK--"
      else
        formatted_stack.each.with_index do |item, i|
          puts sprintf("%03d: %s", formatted_stack.length-i, item)
        end
      end
    end
    print "\nRPN> "
    $_.chomp! if gets
  end

end

if $0 == __FILE__ then
  Ledit.new.main
end
