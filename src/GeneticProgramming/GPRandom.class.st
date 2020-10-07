Class {
	#name : #GPRandom,
	#superclass : #Object,
	#instVars : [
		'random'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'GeneticProgramming-Core'
}

{ #category : #accessing }
GPRandom class >> instance [

	 instance ifNil: [ instance := self new ].
	 ^ instance
]

{ #category : #accessing }
GPRandom class >> resetInstance [

	 instance := nil
]

{ #category : #'as yet unclassified' }
GPRandom >> collectionOfProbabilities: dictionary [

	 | multiplier collection |
	 multiplier := self multiplierOf: dictionary values.
	 collection := OrderedCollection new.
	 dictionary associations do: [ :assoc | 
		 1 to: assoc value * multiplier do: [ :n | 
		 collection add: assoc key ] ].
	 ^ collection
]

{ #category : #initialization }
GPRandom >> initialize [ 
	random := Random seed: 18
]

{ #category : #'as yet unclassified' }
GPRandom >> multiplierOf: numbers [

	 ^ self multiplierOf: numbers from: 0 to: 100
]

{ #category : #'as yet unclassified' }
GPRandom >> multiplierOf: numbers from: begin to: end [

	 ^ (begin to: end by: 10)
		   detect: [ :n | 
			   | num |
			   num := n == 0 ifTrue: [ n + 1 ] ifFalse: [ n ].
			   numbers * num allSatisfy: [ :r | r fractionPart = 0 ] ]
		   ifFound: [ :n | n == 0 ifTrue: [ n + 1 ] ifFalse: [ n ] ]
		   ifNone: [ 
		   self multiplierOf: numbers from: begin * 10 to: end * 10 ]
]

{ #category : #'instance creation' }
GPRandom >> seed: number [
	random seed: number 
]

{ #category : #'as yet unclassified' }
GPRandom >> selectRandomly: collection [

	 | val |
	 val := random nextInt: collection size.
	 "Transcript show:
		 val asString , 'col: ' , collection size asString , String cr."
	 ^ collection at: val
]

{ #category : #'as yet unclassified' }
GPRandom >> selectRandomlyGivenProbabilities: dictionary [

	 ^ self selectRandomly:
		   ((self collectionOfProbabilities: dictionary) 
			    shuffleBy: random)
]
