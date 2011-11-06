#
# Implementation of vector/matrix words.  Returned values must be wrapped
# in an array, otherwise they will be spliced as multiple return values
# into the stack.
#

module RPL
  class Words
    def Words.register_matrix_dict rpl
      rpl.instance_exec do

        # Vector stuff
        defop("+",     [Vector, Vector])  { |a,b| [a+b] }
        defop("-",     [Vector, Vector])  { |a,b| [a-b] }
        defop("*",     [Numeric, Vector]) { |a,b| [a*b] }
        defop("*",     [Vector, Numeric]) { |a,b| [a*b] }
        defop("/",     [Vector, Numeric]) { |a,b| [a/b] }
        defop("dot",   [Vector, Vector])  { |a,b| a.inner_product(b) }
        defop("cross", [Vector, Vector])  { |a,b| [Vector[a[1]*b[2] - a[2]*b[1],
                                                          a[2]*b[0] - a[0]*b[2],
                                                          a[0]*b[1] - a[1]*b[0]]] }
        defop("abs",   [Vector])          { |a|   a.r }

        # Matrix stuff
        defop("+",      [Matrix, Matrix])  { |a,b| [a+b] }
        defop("-",      [Matrix, Matrix])  { |a,b| [a-b] }
        defop("*",      [Matrix, Matrix])  { |a,b| [a*b] }
        defop("*",      [Numeric, Matrix]) { |a,b| [a*b] }
        defop("*",      [Matrix, Numeric]) { |a,b| [a*b] }
        defop("*",      [Matrix, Vector])  { |a,b| [a*b] }
        defop("/",      [Vector, Matrix])  { |a,b| [b.inverse * a] }
        defop("det",    [Matrix])          { |a| a.determinant }
        defop("inv",    [Matrix])          { |a| [a.inverse] }
        defop("diag->", [Vector])          { |a| [Matrix.diagonal(*a)] }
        defop("idn",    [Numeric])         { |n| [Matrix.identity(n)] }
        defop("trn",    [Matrix])          { |a| [a.transpose] }
      end
    end
  end
end
