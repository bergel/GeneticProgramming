Class {
	#name : #GPRandomTest,
	#superclass : #TestCase,
	#category : #'GeneticProgramming-Tests'
}

{ #category : #running }
GPRandomTest >> tearDown [ 
	GPRandom resetInstance.
	super tearDown 
]

{ #category : #tests }
GPRandomTest >> testRandomNumber [

	| collection random |
	random := GPRandom seed: 10.
	collection := (1 to: 100) collect: [ :n | random randomNumber: 3 ].
	self assert: collection asSet size > 1
]

{ #category : #tests }
GPRandomTest >> testRandomlySelect [

	| random collection selected |
	random := GPRandom seed: 1.
	collection := #( 1 1 1 1 1 1 1 1 1 1 2 3 ) asOrderedCollection.
	random shuffleElementsOf: collection.
	selected := (1 to: 100) collect: [ :n | 
		            random randomlySelect: collection ].
	self assert: selected asSet size > 1
]

{ #category : #tests }
GPRandomTest >> testRandomlySelectGivenProbabilities [

	| dict collection random |
	random := GPRandom seed: 10.
	dict := Dictionary new
		        at: 1 put: 100;
		        at: 2 put: 10;
		        at: 3 put: 10;
		        yourself.
	collection := (1 to: 100) collect: [ :n | 
		              random randomlySelectGivenProbabilities: dict ].
	self assert: collection asSet size > 1
]

{ #category : #tests }
GPRandomTest >> testRandomlySelectOfDictionary [

	| random dictionary selected |
	random := GPRandom seed: 1.
	dictionary := Dictionary new 
		at: 'opts' put: #(1 6 3 3 3 5 2);
		at: 'nodeOpts' put: #(6 4 6 2 2 0);
		yourself.
	selected := random randomlySelectOfDictionary: dictionary.
	self assert: selected equals: 'opts' -> 1
]

{ #category : #tests }
GPRandomTest >> testShuffleElementsOf [

	| random collection shuffledCollection |
	random := GPRandom seed: 10.
	collection := #( 1 1 1 1 1 1 1 1 1 1 2 3 ) asOrderedCollection.
	shuffledCollection := #( 1 1 1 1 1 1 1 1 1 1 2 3 )
		                      asOrderedCollection.
	random shuffleElementsOf: collection.
	self assertCollection: collection hasSameElements: shuffledCollection.
	self deny: collection equals: shuffledCollection
]
