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

    @formats[:DEFAULT] = proc { |o| o.inspect }
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

  def print_stack
    if @sequencer.stack.empty? then
      puts "--EMPTY STACK--"
    else
      @sequencer.stack.each.with_index do |obj, i|
        formatter = @formats[obj.class] || @formats[:DEFAULT]
        puts sprintf("%03d: %s", @sequencer.stack.length-i, formatter.call(obj))
      end
    end
  end

  def prompt
    if @lasterr
      STDERR.puts "ERROR: #{@lasterr}"
      @lasterr = nil
    else
      print_stack
    end
    print "\nRPN> "
    $_.chomp! if gets
  end

end

if $0 == __FILE__ then
  Ledit.new.main
end
