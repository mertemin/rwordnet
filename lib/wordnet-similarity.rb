require 'wordnet/pointer'
require 'wordnet/wordnetdb'
require 'wordnet/index'
require 'wordnet/lemma'
require 'wordnet/pointers'
require 'wordnet/pos'
require 'wordnet/synset'

require 'wordnet-ic/ic'
require 'wordnet-ic/wordnetic'
require 'wordnet-ic/similarityindex'

class WordNetSimilarity

	# Initialize similarity object with noun index and BNC corpus.
	def initialize
		@wordIndex = WordNet::NounIndex.instance
		@icIndex = WordNetInfoContent::BNCIndex.instance
	end

	def setWordIndex(newIndex)
		@wordIndex = newIndex
	end

	def setICIndex(newIndex)
		@icIndex = newIndex
	end
	
	# Returns lemma for given word.
	def lemma(word)
		@wordIndex.find(word)
	end
	
	# Returns information content of given lemma. If IC cannot be found returns -1.
	def getICbyLemma(lemma)
		ics = []
		lemma.synset_offset.each do |synset|
			ics.push @icIndex.find("#{synset}#{lemma.pos}")
		end
		if ics.empty?
			-1
		else
			ics.min_by { |ic| ic.ic_result }.ic_result
		end
	end
	
	# Returns corresponding information content to given offset and position.
	def getICbyOffset(offset, pos)
		ic = @icIndex.find("#{offset}#{pos}")
		if ic.nil?
			-1
		else
			ic.ic_result.to_f
		end
	end
	
	# Creates an array of hash trees for given lemma.
	# Each hash tree is a list of synsets from the lowest level synset, the given lemma corresponds to, all the way up to +entity+
	def hTree(lemma)
		path = []
		lemma.synsets.each do |synset|
			i = synset.expanded_hypernym.size + 1
			tree = {}
			tree[i] = synset.synoff.to_i
			i -= 1
			synset.expanded_hypernym.each do |hyp|
				#puts "#{i}) #{hyp.synoff} - #{hyp.gloss}"
				tree[i] = hyp.synoff.to_i
				i -= 1
			end
			path.push tree
		end
		path
	end
	
	def displayHTree(hTree)
		hTree.each do |tree|
			tree.sort.each do |k, v|
				puts "#{k}) #{v}"
			end
			puts ""
		end
	end

	# Given two lemmas, compares lemma's synset trees and returns least common subsumer.
	def getLCS(l1, l2)
		ht1 = hTree(l1)
		ht2 = hTree(l2)
		maxD = 0
		minCO = 0
		minRO = 0
		c1RO = 0
		c1CO = 0
		c2RO = 0
		c2CO = 0
		ht1.each do |t1|
			ht2.each do |t2|
				if(t1.size >= maxD && t2.size >= maxD)
					depth, rootOffset, childOffset = getMaxLCS(t1, t2)
					if(depth >= maxD)
						maxD = depth
						minCO = childOffset
						minRO = rootOffset
						c1CO = t1.max_by { |k, v| k }[1]
						c1RO = t1[1]
						c2CO = t2.max_by { |k, v| k }[1]
						c2RO = t2[1]
					end
				end
				#puts "#{depth} -- #{rootOffset} - #{childOffset}"
			end
		end
		[maxD, minCO, minRO, c1CO, c1RO, c2CO, c2RO]
	end
	
	# Returns the deepest LCS for given two synset trees
	def getMaxLCS(p1, p2)
		i = 1
		rootOffset = p1[i]
		while p1[i] == p2[i] && i <= p1.size && i <= p2.size
			i += 1
		end
		[i-1, rootOffset, p1[i-1]]
	end

	# 2 * IC(LCS) / (IC(synset1) + IC(synset2))
	# http://dl.acm.org/citation.cfm?id=657297
	def simLin(w1, w2)
		l1 = lemma(w1)
		l2 = lemma(w2)
		sim = 0
		if !l1.nil? && !l2.nil?
			depth, lcsCO, lcsRO, c1CO, c1RO, c2CO, c2RO = getLCS(l1, l2)
			ic1 = -Math.log(getICbyOffset(c1CO, "n")/getICbyOffset(c1RO, "n"))
			ic2 = -Math.log(getICbyOffset(c2CO, "n")/getICbyOffset(c2RO, "n"))
			icl = -Math.log(getICbyOffset(lcsCO, "n")/getICbyOffset(lcsRO, "n"))
			sim = ic1 && ic2 && icl ? (2 * icl) / (ic1 + ic2) : 0
			#puts "#{sim} -- #{ic1} - #{ic2} - #{icl}"
		end
		sim
	end
	
	# 1 / (IC(synset1) + IC(synset2) - 2 * IC(LCS)
	# http://arxiv.org/pdf/cmp-lg/9709008.pdf
	def simJnc(w1, w2)
		l1 = lemma(w1)
		l2 = lemma(w2)
		sim = 0
		if !l1.nil? && !l2.nil?
			depth, lcsCO, lcsRO, c1CO, c1RO, c2CO, c2RO = getLCS(l1, l2)
			ic1 = -Math.log(getICbyOffset(c1CO, "n")/getICbyOffset(c1RO, "n"))
			ic2 = -Math.log(getICbyOffset(c2CO, "n")/getICbyOffset(c2RO, "n"))
			icl = -Math.log(getICbyOffset(lcsCO, "n")/getICbyOffset(lcsRO, "n"))
			sim = ic1 && ic2 && icl ? 1 / (-2 * icl + ic1 + ic2) : 0
			#puts "#{sim} -- #{ic1} - #{ic2} - #{icl}"
		end
		sim
	end
end