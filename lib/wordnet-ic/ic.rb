module WordNetInfoContent

# Represents information content (IC) in the WordNet, which demonstrates how much information a synset contains.
class IC
  attr_accessor :identifier, :ic_result, :id

  def initialize(index_line, id = 0)
    @id = (id > 0) ? id : nil
    line = index_line.split(" ")
    
    @identifier = line.shift
    @ic_result = line.shift.to_i
  end
  
  def to_s
    [@identifier, @ic_result].join(",")
  end

  alias word identifier
end

end