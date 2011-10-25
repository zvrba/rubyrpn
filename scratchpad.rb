require './rpl/syntax'

if $0 == __FILE__ then
  rplsyn = RPLSyntax.new
  while true
    begin
      print "rpl$ "
      gets
      tree = rplsyn.parse($_.chomp!)
      p RPLAST.new.apply(tree)
    rescue Parslet::ParseFailed => error
      puts error
    end
  end
end
