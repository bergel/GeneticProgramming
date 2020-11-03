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
	c := super deepCopy. ";
		     evaluationBlock: evaluationBlock;
		     printBlock: printBlock"
	self children do: [ :child | c addChild: child deepCopy ].
	^ c
]

{ #category : #'public access' }
GPCollectionNode >> evaluate: grammar [

	^ children collect: [ :child | child evaluate: grammar]
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandGiven: grammar [

	| node options newCollection |
	node := nil.
	options := grammar shuffleOptions: id.
	newCollection := options
		                 collect: [ :opt | 
		                 (grammar nodeOf: opt children first) expandGiven:
			                 grammar ]
		                 thenReject: [ :n | n isNil ].
	newCollection ifNotEmpty: [ 
		node := (self newNode: grammar) children: newCollection ].
	^ node
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandGiven: grammar depth: anInteger and: booleans [

	| node options newCollection |
	anInteger == 1 ifTrue: [ ^ self newNode: grammar with: anInteger ].
	node := nil.
	options := grammar shuffleOptions: id.
	newCollection := options
		                 collect: [ :opt | 
			|newNode newBooleans |
				newBooleans := booleans deepCopy.
			                 newNode := (grammar nodeOf: opt children first)
				                         expandGiven: grammar
				                         depth: anInteger - 1
				                         and: newBooleans.
			                 (newNode isNotNil and: [ 
				                  newBooleans
					                  inject: false
					                  into: [ :b :e | e or: [ b ] ] ]) ifFalse: [ 
				                 newNode := nil ].
			                 newNode ]
		                 thenReject: [ :n | n isNil ].
	newCollection ifNotEmpty: [ 
		node := (self newNode: grammar with: anInteger) children:
			        newCollection ].
	^ node
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

{ #category : #printing }
GPCollectionNode >> printOn: aStream [

	aStream nextPutAll: '#('.
	children do: [ :child | 
		child printOn: aStream.
		aStream nextPut: Character space ].
	aStream nextPut: $)
]

{ #category : #operations }
GPCollectionNode >> replaceWithValueFrom: visitor [

	^ self children collect: [ :child | child replaceWithValueFrom: visitor ]
]

{ #category : #accessing }
GPCollectionNode >> size: aNumber [
	size := aNumber
]
