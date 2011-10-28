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
  rule (:var)      { (match("[@!]") >> varname).as(:var) }
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

# An identifier can denote either a read/write from a variable (@/! prefix), or
# an executable command (no prefix).

class RPLIdentifier
  def initialize(name)
    @name = name
  end

  def name ;        if execute? then @name else @name[1..-1] end end
  def read? ;       @name[0] == "@" end
  def write? ;      @name[0] == "!"  end
  def execute? ;    not (read? or write?) end
  def to_s ;        @name end
end

# This is the exception class used by commands to report errors.  A RPL error
# has a cause (command/input string that causet the error) and a message which
# explains the condition in more detail.

class RPLException < Exception
  def initialize(message)
    super(message)
  end
end

def rpl_fail(cause, message)
  raise RPLException, "#{message} (offending expression: `#{cause.inspect}`)"
end

class RPLAST < Parslet::Transform
  def RPLAST.MakeMatrix(*rows)
    Matrix[*rows]
  rescue ExceptionForMatrix::ErrDimensionMismatch
    raise rpl_fail(rows.inspect, "inconsistent row lengths in matrix literal")
  end

  rule(:intnum => simple(:x))         { Integer(x) }
  rule(:flonum => simple(:x))         { Float(x) }
  rule(:var    => simple(:x))         { RPLIdentifier.new(x) }
  rule(:op     => simple(:x))         { RPLIdentifier.new(x) }
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
