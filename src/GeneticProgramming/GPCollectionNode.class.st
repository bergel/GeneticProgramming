Class {
	#name : #GPCollectionNode,
	#superclass : #GPAbstractNode,
	#instVars : [
		'size'
	],
	#category : #'GeneticProgramming-Core'
}

{ #category : #copying }
GPCollectionNode >> deepCopy [
| c |
	c := super deepCopy
		     type: self type";
		     evaluationBlock: evaluationBlock;
		     printBlock: printBlock".
	self children do: [ :child | c addChild: child deepCopy ].
	^ c
]

{ #category : #'public access' }
GPCollectionNode >> evaluate: grammar [

	^ children collect: [ :child | child evaluate: grammar]
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandGiven: grammar [

	| result childId |
	size == 0 ifTrue: [ ^ self newNode: grammar ].
	result := (GPRandom instance selectRandomly: (grammar optionsOf: id)) 
		          newNode: grammar.
	result number: grammar nodeNumber.
	childId := result children first id.
	result children:
		((1 to: size) collect: [ :n | grammar expandFrom: childId ]).
	^ result
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandGiven: grammar and: configuration [

	| result childId |
	size == 0 ifTrue: [ ^ self newNode: grammar ].
	result := (self
		           selectedOptionNode: (grammar optionsOf: id)
		           given: configuration) newNode: grammar.
	result number: grammar nodeNumber.
	childId := result children first id.
	result children: ((1 to: size) collect: [ :n | 
			 grammar expandFrom: childId given: configuration ]).
	^ result
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandGiven: configuration grammar: grammar depth: depth and: booleans [

	| node |
	depth == 1 ifTrue: [ ^ self newNode: grammar ].
	node := nil.

	depth > 1 ifTrue: [ 
		| selected randomIndexes options newCollection |
		options := grammar optionsOf: self id.
		randomIndexes := GPRandom instance shuffleElementsOf:
			                 (1 to: options size) asArray.
		selected := false.
		newCollection := (1 to: options size)
			                 collect: [ :n | 
				                 node := (grammar nodeOf:
					                          (options at: (randomIndexes at: n))
						                          children first id)
					                         expandGiven: configuration
					                         grammar: grammar
					                         depth: depth - 1
					                         and: booleans.
				                 selected := selected or: [ 
					                             node isNotNil and: [ 
						                             booleans
							                             inject: false
							                             into: [ :b :e | e or: [ b ] ] ] ].
				                 node ]
			                 thenReject: [ :n | n isNil ].
		newCollection ifNotEmpty: [ 
			node := (self newNode: grammar) children: newCollection ] ].
	"selected ifTrue: [
			node := (self newGiven: grammar) children:
				        (newCollection reject: [ :i | i isNil ]) ] ]."
	^ node
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandGiven: grammar ofSize: aNumber [

	size := aNumber.
	^ self expandGiven: grammar
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandReplacingGiven: visitor and: grammar [

	| result childId cn |
	(id == #Statements and: [ size == 0 ]) ifTrue: [ size := 1 ].
	size == 0 ifTrue: [ ^ self newNode: grammar ].
	result := (grammar randomlySelectOption: id) newNode: grammar.
	childId := result children first.
	cn := (1 to: size) collect: [ :n | 
		      (grammar nodeOf: childId)
			      expandReplacingGiven: visitor
			      and: grammar ].
	result children: cn.
	result value: (cn collect: #value).
	^ result
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandReplacingGiven: visitor grammar: grammar depth: depth and: booleans [

	| result options cn |
	size == 0 ifTrue: [ ^ self newNode: grammar ].
	result := self newNode: grammar.
	cn := OrderedCollection new.
	options := self
		           selectedOptionNode: (grammar optionsOf: id)
		           given: visitor configuration. "grammar optionsOf: id given: visitor configuration."
	options := options
		           collect: [ :option | 
			           | node childId |
			           node := option newNode: grammar.
			           childId := node children first.
			           (grammar nodeOf: childId)
				           expandReplacingGiven: visitor
				           grammar: grammar
				           depth: depth - 1
				           and: booleans ]
		           thenSelect: [ :n | n isNotNil ].
	options size > size
		ifTrue: [ cn := (1 to: size) collect: [ :n | options at: n ] ]
		ifFalse: [ "fill an array with values of options "
			| indexes |
			indexes := grammar shuffle:
				           (self fillArrayOfSize: options size to: size).
			cn := (1 to: size) collect: [ :i | 
				      (options at: (indexes at: i)) newNode: grammar ] ].
	result children: cn.
	result value: (cn collect: #value).
	^ result
]

{ #category : #'as yet unclassified' }
GPCollectionNode >> fillArrayOfSize: size1 to: size2 [
	| aux |
	aux := 0.
	^ (1 to: size2) collect: [ :n | aux := n // size1.
		n == (aux * size1) ifTrue: [ size1 ] ifFalse: [ n - (aux * size1) ] ]
]

{ #category : #initialization }
GPCollectionNode >> initialize [

	super initialize.
	size := 0.
	value := OrderedCollection new
]

{ #category : #initialization }
GPCollectionNode >> print [
		^ String streamContents: [ :str | 
		  str nextPut: $(.
		  children do: [ :child | 
			  str
				  nextPutAll: child print;
				  nextPut: $, ].
		  str nextPut: $) ]
	"str := '( '.
	str := str , children collect: [ :child | child print ] , ')'."
]

{ #category : #operations }
GPCollectionNode >> replaceWithValueFrom: visitor [

	^ self children collect: [ :child | child replaceWithValueFrom: visitor ]
]

{ #category : #accessing }
GPCollectionNode >> size: aNumber [
	size := aNumber
]
