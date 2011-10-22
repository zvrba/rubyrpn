require 'parslet'

class RPLSyntax < Parslet::Parser
  rule (:skipws)  { match('\s').repeat }

  rule (:decnat)   { match('[0-9]').repeat(1) }
  rule (:decint)   { match('-').maybe >> decnat }
  rule (:binint)   { match('0') >> match('[bB]') >> match('[01]').repeat(1) }
  rule (:hexint)   { match('0') >> match('[xX]') >> match('[0-9a-fA-F]').repeat(1) }
  rule (:intnum)   { binint | hexint | decint }
  rule (:floatexp) { match('[eE]') >> decint }
  rule (:flonum)   { decint >> match('[.]') >> decnat >> floatexp.maybe }
  rule (:number)   { flonum.as(:flonum) | intnum.as(:intnum) }

  root (:number)
end

if $0 == __FILE__ then
  rplsyn = RPLSyntax.new
  while true
    begin
      print "rpl$ "
      gets
      p rplsyn.parse($_.chomp!)
    rescue Parslet::ParseFailed => error
      puts error, rplsyn.root.error_tree
    end
  end
end
