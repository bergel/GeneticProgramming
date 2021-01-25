Class {
	#name : #GPNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'instance creation' }
GPNode class >> children: someNodes [
	^ self new children: someNodes
]

{ #category : #'as yet unclassified' }
GPNode >> convertToList: dictionary [
	^ dictionary associations 
		flatCollect: [ :assoc | assoc value collect: [ :val | assoc key -> val ] ]
]

{ #category : #operations }
GPNode >> deepCopy [

	| c |
	c := super deepCopy
		     "evaluationBlock: evaluationBlock;
		     printBlock: printBlock.".
	self children do: [ :child | c addChild: child deepCopy ].
	^ c
]

{ #category : #'collecting leaves' }
GPNode >> expandChildrenGiven: grammar depth: anInteger method: methodName option: optionName and: booleans [
	"to remove"
	| resultNode |
	"self children size == 1 ifTrue: [ 
		^ (grammar nodeOf: self children first)
			  expandGiven: grammar
			  depth: anInteger
			  method: methodName
			  and: booleans ]."
	"(anInteger == 1 and: [ self children size == 1 ]) ifTrue: [ 
		resultNode := self newNode: grammar with: anInteger.
		resultNode children at: 1 put: ((grammar nodeOf: self children first)
			  expandGiven: grammar
			  depth: anInteger
			  method: methodName
			  and: booleans).
		^ resultNode
		 ]."
	"(anInteger > 1 and: [ self children size == 1 ]) ifTrue: [ 
		^ (grammar nodeOf: self children first)
			  expandGiven: grammar
			  depth: anInteger
			  method: methodName
			  and: booleans ]."
	anInteger > 1 ifTrue: [
		resultNode := self newNode: grammar with: anInteger.
		"nVal := OrderedCollection new."
		children doWithIndex: [ :child :index | 
			| newChild |
			newChild := (grammar nodeOf: child)
				            expandGiven: grammar
				            depth: anInteger - 1
								method: methodName
				            and: booleans.
			newChild
				ifNil: [ ^ nil ]
				ifNotNil: [ resultNode children at: index put: newChild.
					"nVal add: newChild nodeValue" ] ].
		"resultNode nodeValue: nVal" ].
	^ resultNode
]

{ #category : #'collecting leaves' }
GPNode >> expandGiven: grammar depth: anInteger method: methodName and: booleans [
	"to remove"
	| node assocs  |
	anInteger == 1 ifTrue: [ booleans push: false. ^ nil ].
	node := nil.
	assocs := grammar shuffle: (self convertToList: (grammar allOptionsOf: id)).
	assocs
		detect: [ :assoc | | bool prevSize size |
			prevSize := booleans size.
			node := assoc key = 'nodeOptions'
				ifTrue: [ (grammar nodeOf: assoc value) expandGiven: grammar depth: anInteger - 1 method: methodName and: booleans ]
				ifFalse: [ assoc value
				        expandChildrenGiven: grammar
				        depth: anInteger
						  method: methodName
						  option: assoc key
				        and: booleans ].
			size := booleans size.
			bool := (self methodDepthBlock: methodName) valueWithPossibleArgs: (Array with: node with: booleans).
			(methodName = #full and: [(size - prevSize) > 0]) ifTrue: [ 
				1 to: (size - prevSize) do: [:n | booleans pop ] ].
			bool ]
		ifNone: [ node := nil ].
	^ node
]

{ #category : #testing }
GPNode >> isComplexNode [

	^ true
]

{ #category : #initialization }
GPNode >> printOn: aStream [

	aStream nextPut: $(.
	children do: [ :child | 
		child printOn: aStream.
		aStream	nextPut: Character space ].
	aStream nextPut: $)
]
