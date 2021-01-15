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
