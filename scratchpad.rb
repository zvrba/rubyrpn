# Parslet and parser classes generate many warnings
require './rpl/syntax'

$VERBOSE = true
require './rpl/sequencer'

sequencer = RPLSequencer.new
formats = {}

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
