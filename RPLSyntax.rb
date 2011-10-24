require 'parslet'
require 'matrix'

#
# The syntax parser
#

class RPLSyntax < Parslet::Parser
  # Low-level lexical elements
  rule (:ws)       { match('\s').repeat }
  rule (:decdigit) { match('[0-9]') }
  rule (:decnat)   { decdigit.repeat(1) }
  rule (:decint)   { match('-').maybe >> decnat }
  rule (:binint)   { match('0') >> match('[bB]') >> match('[01]').repeat(1) }
  rule (:hexint)   { match('0') >> match('[xX]') >> match('[0-9a-fA-F]').repeat(1) }
  rule (:intnum)   { binint | hexint | decint }
  rule (:floatexp) { match('[eE]') >> decint }
  rule (:flonum)   { decint >> match('[.]') >> decnat >> floatexp.maybe }

  # Lexical atoms -- :flonum, :intnum, :var, :op
  rule (:number)   { (flonum.as(:flonum) | intnum.as(:intnum)) }
  rule (:var)      { (match("'") >> match('[a-zA-Z0-9_]').repeat(1)).as(:var) }
  rule (:op)       { (match('[+*/a-zA-Z!@$%^&=|~<>?-]').repeat(1)).as(:op) }
  rule (:atom)     { number | var | op }

  # Composites -- vector, matrix, list
  rule (:vector)   { match('\[') >> ws >> (number >> ws).repeat(1).as(:vector) >> match('\]') }
  rule (:matrix)   { match('\[') >> ws >> (vector >> ws).repeat(1).as(:matrix) >> match('\]') }
  rule (:list)     { match('\{') >> ws >> (atom >> ws).repeat(1).as(:list) >> match('}') }
  rule (:comp)     { vector | matrix | list }

  # Acceptable input
  rule (:input)    { ((atom | comp) >> ws).repeat(1) }
  root (:input)
end

#
# AST: convert to ruby's built-in classes; don't need anything fancy
#

class RPLAST < Parslet::Transform
  rule(:intnum => simple(:x))         { Integer(x) }
  rule(:flonum => simple(:x))         { Float(x) }
  rule(:var    => simple(:x))         { String(x) }
  rule(:op     => simple(:x))         { String(x) }
  rule(:vector => sequence(:x))       { Vector[*x] }
  rule(:list   => sequence(:x))       { Array[*x] }
  rule(:matrix => sequence(:x))       {
    begin
      Matrix[*x]
    rescue ExceptionForMatrix::ErrDimensionMismatch => err
      nil
    end }
end

if $0 == __FILE__ then
  rplsyn = RPLSyntax.new
  while true
    begin
      print "rpl$ "
      gets
      tree = rplsyn.parse($_.chomp!)
      p RPLAST.new.apply(tree)
    rescue Parslet::ParseFailed => error
      puts error, rplsyn.root.error_tree
    end
  end
end
