Class {
	#name : #GPCollectionNode,
	#superclass : #GPAbstractNode,
	#instVars : [
		'size'
	],
	#category : #'GeneticProgramming-Core'
}

{ #category : #accessing }
GPCollectionNode class >> transform: node [
	^ self new children: (Array with: node)
]

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
GPCollectionNode >> expand: grammar [

	| options |
	options := self getOptions: grammar.
	self children: options
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandGiven: grammar [

	| node | 
	node := self newNode: grammar.
	node children: (node getOptions: grammar).
	node nodeValue: (node children collect: [:ch | ch nodeValue ]).
	"node := nil.
	options := grammar randomOptions: id.
	newCollection := options
		                 collect: [ :opt | 
		                 (grammar nodeOf: opt children first) expandGiven:
			                 grammar ]
		                 thenReject: [ :n | n isNil ].
	newCollection ifNotEmpty: [ 
		node := (self newNode: grammar) children: newCollection ]."
	^ node
]

{ #category : #'collecting leaves' }
GPCollectionNode >> expandGiven: grammar depth: anInteger method: methodName and: booleans [
	"^ self newNode: grammar with: anInteger"
	| node newCollection |
	"anInteger == 1 ifTrue: [ ^ self newNode: grammar with: anInteger ]."
	(anInteger == 1 and: [ size == 0 ]) ifTrue: [ ^ self newNode: grammar with: anInteger ].
	node := nil.
	newCollection := (grammar randomOptionsOf: id)
		                 collect: [ :opt | 
			                 | newNode newBooleans bool |
			                 newBooleans := booleans deepCopy.
			                 newNode := (grammar nodeOf: opt children first)
				                            expandGiven: grammar
				                            depth: anInteger - 1
													method: methodName
				                            and: newBooleans.
								 bool := (self methodDepthBlock: methodName) valueWithPossibleArgs: (Array with: newNode with: newBooleans).
			                 "(newNode isNotNil and: [ 
				                  newBooleans
					                  inject: false
					                  into: [ :b :e | e or: [ b ] ] ]) ifFalse: [ 
				                 newNode := nil ]."
			                 bool ifTrue: [ methodName = #grow ifTrue: [ booleans push: true ]. 
				newNode] ifFalse: [ nil ] ]
		                 thenReject: [ :n | n isNil ].
	newCollection ifNotEmpty: [  | indexes |
		newCollection size < size 
			ifTrue: [
				indexes := grammar shuffle: (self fillArrayOfSize: newCollection size to: size).
				node := (self newNode: grammar with: anInteger)
			        children: (indexes collect: [:i | (newCollection at: i) deepCopy ]);
			        yourself ] 
			ifFalse: [ indexes := grammar shuffle: (1 to: size) asArray.
				node := (self newNode: grammar with: anInteger)
			        children: (indexes collect: [:i | newCollection at: i ]);
			        yourself ].
		node nodeValue: (node children collect: [:ch | ch nodeValue ])
		"node := (self newNode: grammar with: anInteger)
			        children: newCollection;
			        yourself "].
	^ node
]

{ #category : #'as yet unclassified' }
GPCollectionNode >> fillArrayOfSize: size1 to: size2 [
	| aux |
	aux := 0.
	^ (1 to: size2) collect: [ :n | aux := n // size1.
		n == (aux * size1) ifTrue: [ size1 ] ifFalse: [ n - (aux * size1) ] ]
]

{ #category : #translating }
GPCollectionNode >> generateAST: visitor [

	"(id == #Statements and: [ size == 0 ]) ifTrue: [ self size: 1 ].
	size == 0 ifTrue: [ ^ OrderedCollection new ].
	(id isNotNil and: [ children isEmpty ]) ifTrue: [ 
	self expand: visitor grammar]."
	^ children collect: [ :child | child generateAST: visitor ]
]

{ #category : #'as yet unclassified' }
GPCollectionNode >> getOptions: grammar [

	| options indexes |
	options := (grammar randomOptionsOf: id) collect: [ :node | 
		           node children first ].
	indexes := grammar shuffle:
		           (self fillArrayOfSize: options size to: size).
	^ indexes collect: [ :index | 
		  grammar expandFrom: (options at: index) ]
]

{ #category : #initialization }
GPCollectionNode >> initialize [

	super initialize.
	size := 0
]

{ #category : #testing }
GPCollectionNode >> isCollectionNode [

	^ true
]

{ #category : #'instance creation' }
GPCollectionNode >> newNode: grammar [
	| node |
	node := super newNode: grammar.
	node size: size.
	^ node
]

{ #category : #'instance creation' }
GPCollectionNode >> newNode: grammar with: aNumber [
	| node |
	node := self newNode: grammar.
	node idNumber: grammar nodeNumber;
		depth: aNumber.
	^ node
]

{ #category : #printing }
GPCollectionNode >> printOn: aStream [

	aStream nextPutAll: '#('.
	children do: [ :child | 
		child printOn: aStream.
		aStream nextPut: Character space ].
	aStream nextPut: $)
]

{ #category : #accessing }
GPCollectionNode >> size: aNumber [
	size := aNumber
]
