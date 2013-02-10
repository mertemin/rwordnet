require 'singleton'
module WordNetInfoContent

# ICIndex is a WordNet-InfoContent lexicon. Note that Index is the base class; you probably want to be using the BNCIndex, BrownIndex, etc. classes instead.
# Note that Indices are Singletons -- get an Index object by calling <POS>Index.instance, not <POS>Index.new.
class ICIndex
  # Create a new index for the given part of speech. +file+ can be one of +noun+, +verb+, +adj+, or +adv+.
  def initialize(file)
    @file = file
    @db = {}
    
    @finished_reading = false
  end
  
  # Find a lemma for a given word. Returns a Lemma which can then be used to access the synsets for the word.
  def find(ic_identifier)
    # Look for the lemma in the part of the DB already read...
    return @db[ic_identifier] if @db.include?(ic_identifier)
    
    return nil if @finished_reading
    
    # If we didn't find it, read in some more from the DB.
    index = WordNetIC.open(File.join(WordNetIC.path,"#{@file}"))

    ic_counter = 1
    if not index.closed?
      loop do
        break if index.eof?
        line = index.readline
        lemma = IC.new(line, ic_counter); ic_counter += 1
        @db[lemma.word] = lemma
        if line =~ /^#{ic_identifier} /
          return lemma
        end
      end
      index.close
    end
    
    @finished_reading = true
    
    # If we *still* didn't find it, return nil. It must not be in the database...
    return nil
  end
end

# An Index of BNC
class BNCIndex < ICIndex
  include Singleton
  
  def initialize
    super("ic-bnc.dat")
  end
end

# An Index of Brown Dictionary
class BrownIndex < ICIndex
  include Singleton

  def initialize
    super("ic-brown.dat")
  end
end

# An Index of Semcor
class SemcorIndex < ICIndex
  include Singleton

  def initialize
    super("ic-semcor.dat")
  end
end

# An Index of TreeBank
class TreebankIndex < ICIndex
  include Singleton

  def initialize
    super("ic-treebank.dat")
  end
end

end
