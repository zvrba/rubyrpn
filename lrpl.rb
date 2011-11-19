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

    @formats[:DEFAULT]  = "%p"
    @formats[:WORDSIZE] = 64
    @formats[Integer]   = "%d"
    @formats[Float]     = "%f"
  end

  def main
    while (line = prompt)
      if line =~ /^\./ then
        line = line.split
        cmd  = "do_#{line[0][1..-1]}"
        if not self.respond_to?(cmd, true) then
          @lasterr = "UNKNOWN META-COMMAND: #{line[0]} (#{cmd})"
        else
          self.send(cmd.to_sym, line[1..-1])
        end
      else
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
  end

private

  def print_stack
    if @sequencer.stack.empty? then
      puts "--EMPTY STACK--"
    else
      @sequencer.stack.each.with_index do |obj, i|
        format = "%03d: " + find_format(obj)
        puts sprintf(format, @sequencer.stack.length-i, obj)
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

  def find_format(obj)
    k = obj.class
    while k != Object
      return @formats[k] if @formats[k]
      k = k.superclass
    end
    return @formats[:DEFAULT]
  end

  # COMMAND HANDLERS

  def do_quit(args)
    exit
  end

  def do_dec(args)
    @formats[Integer] = "%d"
  end

  def do_hex(args)
    w = @formats[:WORDSIZE] / 4
    @formats[Integer] = "%0#{w}X"
  end

  def do_ws(args)
    @formats[:WORDSIZE] = args[0].to_i
  end

end

if $0 == __FILE__ then
  Ledit.new.main
end
