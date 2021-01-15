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

{ #category : #'public access' }
GPNode >> evaluate: grammar [

	 ^ children size == 1
		   ifTrue: [ children first evaluate: grammar ]
		   ifFalse: [ 
			   (children first evaluate: grammar)
				   perform: (children second evaluate: grammar)
				   withEnoughArguments:
				   ((children copyFrom: 3 to: children size) collect: [ :child | 
					    child evaluate: grammar ]) ]
]

{ #category : #'public access' }
GPNode >> evaluate: grammar given: configuration [

	 ^ children size == 1
		   ifTrue: [ children first evaluate: grammar given: configuration ]
		   ifFalse: [ 
			   (children first evaluate: grammar given: configuration)
				   perform: (children second evaluate: grammar given: configuration)
				   withEnoughArguments:
					   ((children copyFrom: 3 to: children size) collect: [ :child | 
						    child evaluate: grammar given: configuration ]) ]
]

{ #category : #'collecting leaves' }
GPNode >> expandChildrenGiven: grammar and: optionKey [

	| resultNode |
	"problem is here"
	optionKey = 'nodeOptions' ifTrue: [ 
		^ (grammar nodeOf: self children first) expandGiven: grammar ].
	"self children size == 1 ifTrue: [ 
		^ (grammar nodeOf: self children first) expandGiven: grammar ]."
	"evaluate when execute here"
	resultNode := self newNode: grammar.
	"nVal := OrderedCollection new."
	children doWithIndex: [ :child :index | 
		| newChild |
		newChild := (grammar nodeOf: child) expandGiven: grammar.
		newChild
			ifNil: [ ^ nil ]
			ifNotNil: [ resultNode children at: index put: newChild.
				"nVal add: newChild nodeValue" ] ].
	"resultNode nodeValue: nVal."
	^ resultNode
]

{ #category : #'collecting leaves' }
GPNode >> expandChildrenGiven: grammar depth: anInteger method: methodName and: booleans [

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
	anInteger > 1 
		ifFalse: [ booleans push: false ] 
		ifTrue: [ resultNode := self newNode: grammar with: anInteger.
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
GPNode >> expandChildrenGiven: grammar depth: anInteger method: methodName option: optionName and: booleans [

	| resultNode |
	"self children size == 1 ifTrue: [ 
		^ (grammar nodeOf: self children first)
			  expandGiven: grammar
			  depth: anInteger
			  method: methodName
			  and: booleans ]."
	(anInteger == 1 and: [ self children size == 1 ]) ifTrue: [ 
		resultNode := self newNode: grammar with: anInteger.
		resultNode children at: 1 put: ((grammar nodeOf: self children first)
			  expandGiven: grammar
			  depth: anInteger
			  method: methodName
			  and: booleans).
		^ resultNode
		 ].
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
GPNode >> expandGiven: grammar [
	| assoc |
	assoc := grammar randomlySelectOption: id.
	^ [assoc value expandChildrenGiven: grammar and: assoc key] 
		on: MessageNotUnderstood 
		do: [ (grammar nodeOf: assoc value) expandGiven: grammar "expandChildrenGiven: grammar and: assoc key" ].

	"| result |
	result := (GPRandom instance selectRandomly: (grammar optionsOf: id)) 
		          newNode: grammar.
	result number: grammar nodeNumber.
	result children doWithIndex: [ :child :index | 
		result children at: index put: (grammar expandFrom: child) ].
	^ result"
]

{ #category : #'collecting leaves' }
GPNode >> expandGiven: grammar depth: anInteger method: methodName and: booleans [

	| node assocs  |
	node := nil.
	assocs := self convertToList: (grammar allOptionsOf: id).
	assocs
		detect: [ :assoc | | bool prevSize size |
			prevSize := booleans size.
			node := assoc key = 'nodeOptions'
				ifTrue: [ (grammar nodeOf: assoc value) expandGiven: grammar depth: anInteger method: methodName and: booleans ]
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

{ #category : #accessing }
GPNode >> nodeValue [
	nodeValue := self children collect: [:ch | ch nodeValue ].
	^ nodeValue 
]

{ #category : #initialization }
GPNode >> printOn: aStream [

	aStream nextPut: $(.
	children do: [ :child | 
		child printOn: aStream.
		aStream	nextPut: Character space ].
	aStream nextPut: $)
]
