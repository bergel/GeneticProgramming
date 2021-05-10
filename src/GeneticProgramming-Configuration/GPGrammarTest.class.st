Class {
	#name : #GPGrammarTest,
	#superclass : #GPAbstactEngineTest,
	#category : #'GeneticProgramming-Configuration-Grammar'
}

{ #category : #initialization }
GPGrammarTest >> configurationClass [
	^ GPGrammarConfiguration 
]

{ #category : #tests }
GPGrammarTest >> testAllLeaves [
	| i |
	20 timesRepeat: [ 
		i := configuration createNewIndividual.
		"self deny: i isLeaf."
		self assert: (i allLeaves allSatisfy: #isLeaf) ].
]

{ #category : #tests }
GPGrammarTest >> testIsLeaf [	
	"20 timesRepeat: [ 
		self deny: configuration createNewIndividual allLeaves isLeaf ].
	20 timesRepeat: [ 
		self assert: configuration newTerminal isLeaf ]."
]

{ #category : #tests }
GPGrammarTest >> testMutate [
	| i1 i2 |
	"engine createInitialPopulation.
	i1 := engine randomElementOf: engine population."
	GPRandom seed: 1.
	i1 := configuration newFunction: #E.
	i2 := i1 deepCopy.
	configuration mutate: i2.
	self deny: i1 print equals: i2 print
	
]

{ #category : #tests }
GPGrammarTest >> testMutate2 [
	| i1 i2 |
	"engine createInitialPopulation.
	i1 := engine randomElementOf: engine population."
	GPRandom seed: 10.
	i1 := configuration newFunction: #T.
	i2 := i1 deepCopy.
	configuration mutate: i2.
	self deny: i1 print equals: i2 print
	
]

{ #category : #tests }
GPGrammarTest >> testMutate3 [
	| i1 i2 |
	"engine createInitialPopulation.
	i1 := engine randomElementOf: engine population."
	GPRandom seed: 1.
	i1 := configuration newFunction: #AddOp.
	i2 := i1 deepCopy.
	configuration mutate: i2.
	self deny: i1 print equals: i2 print
	
]

{ #category : #tests }
GPGrammarTest >> testMutation [
	| i1 i2 |
	engine createInitialPopulation.
	i1 := engine mutation.
	"self assert: i1 class == GPNode."
	i2 := engine mutation.
	"self assert: i2 class == GPNode."
	self assert: i1 print ~= i2 print
]

{ #category : #tests }
GPGrammarTest >> testSelectOptionGiven [
	| options weights |
	options := (1 to: 5) asArray.
	weights := #(10 1 1 1 1).
	self assert: (configuration selectOption: options given: weights) equals: 1
	
]

{ #category : #tests }
GPGrammarTest >> testSelectValueForRule [
	configuration forRule: #E putWeights: #(10 1 1).
	self assert: (configuration selectValue: #(4 2 5) forRule: #E) equals: 4
]

{ #category : #tests }
GPGrammarTest >> testSelectValueForRuleWithMoreOptionsThanWeights [
	configuration forRule: #E putWeights: #(10).
	self assert: (configuration selectValue: #(9 5 2 7) forRule: #E) equals: 9
]

{ #category : #tests }
GPGrammarTest >> testSelectValueForRuleWithMoreWeightsThanOptions [
	configuration forRule: #E putWeights: #(10 2 1 3 5).
	self assert: (configuration selectValue: #(8 3 2) forRule: #E) equals: 8
]

{ #category : #tests }
GPGrammarTest >> testTournament [
	| i1 i2 |
	engine createInitialPopulation;
	rankedIndividuals.
	i1 := engine tournament.
	self assert: (i1 isKindOf: GPAbstractNode).
	i2 := engine tournament.
	self assert: (i2 isKindOf: GPAbstractNode).
	self assert: i1 print ~= i2 print
]
