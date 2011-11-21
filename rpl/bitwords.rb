#
# Implementation of bit-operations
#

module RPL
  class Words
    def Words.register_bit_dict rpl
      rpl.instance_exec do
        # get/set wordsize
        defop("rcws", [])        { self.wordsize }
        defop("stws", [Integer]) { |ws| self.wordsize = ws ; nil }

        defop("and",  [Integer, Integer]) { |a,b| (a&b)  & @wordmask }
        defop("or",   [Integer, Integer]) { |a,b| (a|b)  & @wordmask }
        defop("xor",  [Integer, Integer]) { |a,b| (a^b)  & @wordmask }
        defop("not",  [Integer])          { |x|   (~x)   & @wordmask }

        defop("shl",  [Integer])          { |x|   (x<<1) & @wordmask }
        defop("shlx", [Integer, Integer]) { |a,b| (a<<b) & @wordmask }
        defop("shr",  [Integer])          { |x|   (x>>1) & @wordmask }
        defop("shrx", [Integer, Integer]) { |a,b| (a>>b) & @wordmask }
      end
    end
  end
end
