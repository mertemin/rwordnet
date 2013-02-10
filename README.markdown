# A Ruby interface of WordNet-Similarity #

## About ##

This library simply adds similarity computation capability to rwordnet[https://github.com/doches/rwordnet]. The similarity computation is implemented based on WordNet-InfoContent-3.0[http://wn-similarity.sourceforge.net/] published by Ted Pedersen.

## Usage ##

As a quick example, consider finding similarity between two words:

    require 'rubygems'
    require 'wordnet-similarity'
    
    wn = WordNetSimilarity.new
    wn.simLin("car", "automobile")
    => 1.0
    wn.simJnc("car", "fruit")
    => 0.0704056502331114

Initally word index initialized with noun and IC index with BNC corpus. If you want to change these use `setWordIndex` and `setICIndex`. Here is an example code snippet to compute similarity between two verbs using Penn Treebank corpus. 

    require 'rubygems'
    require 'wordnet-similarity'
    
    wn = WordNetSimilarity.new
    wn.setWordIndex WordNet::VerbIndex.instance
    wn.setICIndex WordNetInfoContent::TreebankIndex.instance