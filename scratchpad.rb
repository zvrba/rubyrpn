require './rpl/syntax'
require './rpl/sequencer'

sequencer = RPLSequencer.new
formats = {}

while true
  print "rpl> "
  sequencer.interpret(gets.chomp!)
  sequencer.format_stack(formats).each do |item|
    puts item
  end
  puts "\n"
end
