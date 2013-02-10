module WordNetInfoContent

# Represents the WordNet Information Content database
class WordNetIC
  # By default, use the bundled WordNet-InfoContent
  @@path = File.join(File.dirname(__FILE__),"/../../WordNet-InfoContent-3.0/")
  @@files = {}

  # To use your own WordNet-InfoContent installation (rather than the one bundled with rwordnet-similarity):
  def WordNetIC.path=(path_to_wordnet)
    @@path = path_to_wordnet
  end
  
  # Returns the path to the WordNet-InfoContent installation currently in use.
  def WordNetIC.path
    @@path
  end
  
  # Look up an IC in WordNet-InfoContent. Returns the corresponding IC of given word.
  def WordNetIC.find(word)
    lemmas = []
    [BNCIndex, BrownIndex, SemcorIndex, TreebankIndex].each do |index|
      lemmas.push index.instance.find(word)
    end
    return lemmas.flatten.reject { |x| x.nil? }
  end
  
  # Register a new DB file handle. You shouldn't need to call this method; it's called automatically every time you open an index or data file.
  def WordNetIC.open(path)
    # If the file is already open, just return the handle.
    return @@files[path] if @@files.include?(path) and not @@files[path].closed?
    
    # Open and store 
    @@files[path] = File.open(path,"r")
    return @@files[path]
  end
  
  # You should call this method after you're done using WordNet.
  def WordNetIC.close
    WordNetIC.finalize(0)
  end
  
  def WordNetIC.finalize(id)
    @@files.each_value do |handle| 
      begin
        handle.close
      rescue IOError
        ; # Keep going, close the next file.
      end
    end
  end
end

end
