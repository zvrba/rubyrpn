# This file defines the RPL parser and additional types that may be found on
# the stack alongside with standard ruby types (Integer, Float, etc.)

require 'parslet'
require 'matrix'

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
  rule (:varname)  { match('[a-zA-Z0-9_]').repeat(1) }
  rule (:var)      { (match("[@!]").maybe >> varname).as(:varname) }
  rule (:op)       { (match('[0-9+*/a-zA-Z!@$%^&=|~<>?-]').repeat(1)).as(:op) }
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

class RPLIdentifier
  def initialize(name)
    @name = name
  end

  def name
    if command? then @name else @name[1..-1] end
  end

  def mode_read?
    name[0] == "@"
  end

  def mode_write?
    name[0] == "!"
  end

  def command?
    not (mode_read? or mode_write?)
  end
end

# Errors have a cause and a message.  The cause is the immediate input string
# that caused the error.

class RPLError
  def initialize(cause, message)
    
  end
end

class RPLAST < Parslet::Transform
  def RPLAST.MakeMatrix(*rows)
    Matrix[*rows]
  rescue ExceptionForMatrix::ErrDimensionMismatch
    $!
  end

  rule(:intnum => simple(:x))         { Integer(x) }
  rule(:flonum => simple(:x))         { Float(x) }
  rule(:var    => simple(:x))         { RPLQuotedId.new(x) }
  rule(:op     => simple(:x))         { RPLPlainId.new(x) }
  rule(:vector => sequence(:x))       { Vector[*x] }
  rule(:list   => sequence(:x))       { Array[*x] }
  rule(:matrix => sequence(:x))       { RPLAST.MakeMatrix(*x) }
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
      puts error
    end
  end
end
