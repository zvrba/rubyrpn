# Parslet and parser classes generate many warnings
require './rpl/syntax'

$VERBOSE = true
require './rpl/sequencer'

sequencer = RPLSequencer.new
formats = {}

module RPLArithmetic
  def RPLArithmetic.extend_object(rpl)
    rpl.register_op("+", [Numeric, Numeric]) { |a,b| a+b }
    rpl.register_op("-", [Numeric, Numeric]) { |a,b| a-b }
    rpl.register_op("*", [Numeric, Numeric]) { |a,b| a*b }
    rpl.register_op("/", [Numeric, Numeric]) { |a,b| a/b }

    rpl.register_op("neg", [Numeric]) { |x| -x }
    rpl.register_op("abs", [Numeric]) { |x| x.abs }
  end
end

sequencer.extend(RPLArithmetic)

while true
  print "rpl> "
  sequencer.interpret(gets.chomp!)
  formatted_stack = sequencer.format_stack(formats)
  depth = formatted_stack.length

  sequencer.format_stack(formats).each.with_index do |item,i|
    puts(sprintf("%03d: ", depth-i) + item)
  end
  puts "\n"
end
