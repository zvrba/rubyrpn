#
# This file defines the RPL parser and AST tree walkers.
#

require 'parslet'
require 'matrix'

module RPL

  class Parser < Parslet::Parser
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

    # Lexical atoms -- :flonum, :intnum, :name, :op
    rule (:number)   { (flonum.as(:flonum) | intnum.as(:intnum)) }
    rule (:name)     { match('[0-9+*/a-zA-Z!@$%^&=|~<>?:;-]').repeat(1).as(:name) }
    rule (:atom)     { number | name }

    # Composites -- vector, matrix, list
    rule (:vector)   { match('\[') >> ws >> (number >> ws).repeat(1).as(:vector) >> match('\]') }
    rule (:matrix)   { match('\[') >> ws >> (vector >> ws).repeat(1).as(:matrix) >> match('\]') }
    rule (:list)     { match('\{') >> ws >> (atom >> ws).repeat(1).as(:list) >> match('}') }
    rule (:comp)     { vector | matrix | list }

    # Acceptable input
    rule (:input)    { ((atom | comp) >> ws).repeat(1) }
    root (:input)
  end

  class Walker < Parslet::Transform
    def Walker.MakeMatrix(*rows)
      Matrix[*rows]
    rescue ExceptionForMatrix::ErrDimensionMismatch
      RPL.fail(rows.inspect, "inconsistent row lengths in matrix literal")
    end

    rule(:intnum => simple(:x))         { Integer(x) }
    rule(:flonum => simple(:x))         { Float(x) }
    rule(:name   => simple(:x))         { Name.new(x.to_s) }
    rule(:vector => sequence(:x))       { Vector[*x] }
    rule(:list   => sequence(:x))       { Array[*x] }
    rule(:matrix => sequence(:x))       { Walker.MakeMatrix(*x) }
  end

end

if $0 == __FILE__ then
  require_relative 'helpers.rb'
  parser = RPL::Parser.new
  walker = RPL::Walker.new

  while true
    begin
      print "rpl$ "
      gets
      tree = parser.parse($_.chomp!)
      p walker.apply(tree)
    rescue Parslet::ParseFailed => error
      puts error
    end
  end
end
