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

{ #category : #'instance creation' }
GPRandom class >> seed: aNumber [

	self resetInstance.
	^ self instance seed: aNumber
]

{ #category : #enumerating }
GPRandom >> collectionOfProbabilities: dictionary [

	"```Smalltalk
d := Dictionary new.
d at: 2 put: 10;
at: 4 put: 3;
at: 8 put: 4;
yourself.

(GPRandom seed: 10) collectionOfProbabilities: d. ```

Return the collection: #(2 2 2 2 2 2 2 2 2 2 8 8 8 8 4 4 4)


Given a dictionary with values and their corresponding weights it 
returns a new collection with each key repeated the number of times of 
its correspondig weight (transformed to integer) "

	| multiplier collection |
	multiplier := self multiplierOf: dictionary values.
	collection := OrderedCollection new.
	dictionary associations do: [ :assoc | 
		1 to: assoc value * multiplier do: [ :n | collection add: assoc key ] ].
	^ collection
]

{ #category : #initialization }
GPRandom >> initialize [ 
	random := Random seed: 18
]

{ #category : #rounding }
GPRandom >> multiplierOf: numbers [
	"```Smalltalk
	r := GPRandom seed: 1.
	r multiplierOf: #(0.5 0.4 0.2)
	```
	return the value 10
	
	```
	r := GPRandom seed: 1.
	r multiplierOf: #(0.0003 0.03 0.114 4 5.34 1.323)```
	
	return the value 10000"
	
	"return the multiplier necessary to transform all the numbers to integer"
	^ self multiplierOf: numbers from: 0 to: 100
]

{ #category : #rounding }
GPRandom >> multiplierOf: numbers from: begin to: end [
	"r := GPRandom seed: 3.
	r multiplierOf: #(0.8 2 3.5 0.47) from: 1 to: 10.
	
	return the value 100"
	^ (begin to: end by: 10)
		  detect: [ :n | 
			  | num |
			  num := n == 0
				         ifTrue: [ n + 1 ]
				         ifFalse: [ n ].
			  numbers * num allSatisfy: [ :r | r fractionPart = 0 ] ]
		  ifFound: [ :n | 
			  n == 0
				  ifTrue: [ n + 1 ]
				  ifFalse: [ n ] ]
		  ifNone: [ 
		  self multiplierOf: numbers from: begin * 10 to: end * 10 ]
]

{ #category : #enumerating }
GPRandom >> randomlySelect: collection [

	 ^ collection at: (random nextInt: collection size)
]

{ #category : #enumerating }
GPRandom >> randomlySelectGivenProbabilities: dictionary [

	 ^ self randomlySelect:
		   ((self collectionOfProbabilities: dictionary) 
			    shuffleBy: random)
]

{ #category : #'instance creation' }
GPRandom >> seed: number [
	random seed: number 
]

{ #category : #shuffling }
GPRandom >> shuffleElementsOf: collection [

	 ^ collection shuffleBy: random
]
