Class {
	#name : #GPLeafNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #copying }
GPLeafNode >> deepCopy [
	| newNode |
	newNode := super deepCopy.
	"newNode evaluationBlock: self evaluationBlock;
	printBlock: self printBlock."
	"newNode nodeValue: nodeValue deepCopy."
	^ newNode
]

{ #category : #'public access' }
GPLeafNode >> evaluate: grammar [

	 ^ self nodeValue
]

{ #category : #'public access' }
GPLeafNode >> evaluate: grammar given: configuration [
	
	^ self evaluate: grammar "(self selectedOptionNode: (grammar optionsOf: id) given: configuration) deepCopy"
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandChildrenGiven: grammar and: optionKey [
	^ self expandGiven: grammar
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: context [
	| node |
	node := self newNode: context.
	node nodeValue: (self selectOption: context).
	^ node
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: grammar depth: anInteger and: booleans [
	| node |
	booleans add: anInteger == 1.
	node := self newNode: grammar with: anInteger.
	node nodeValue: (self selectOption: grammar).
	^ node
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: grammar depth: anInteger method: methodName and: booleans [
	
	"^ self expandGiven: grammar depth: anInteger and: booleans"
	| node options  |
	options := grammar nodeOptionsOf: id.
	(options isEmpty or: [ anInteger = 1 or: [ methodName = #grow ] ]) ifTrue: [ ^ self expandGiven: grammar depth: anInteger and: booleans ].
	node := nil.
	options := grammar shuffle: (options).
	options
		detect: [ :option | | bool prevSize size |
			prevSize := booleans size.
			node := option isSymbol
				ifTrue: [ (grammar nodeOf: option) expandGiven: grammar depth: anInteger method: methodName and: booleans ]
				ifFalse: [ nil].
			size := booleans size.
			bool := (self methodDepthBlock: methodName) valueWithEnoughArguments: (Array with: node with: booleans).
			(methodName = #full and: [(size - prevSize) > 0]) ifTrue: [ 
				1 to: (size - prevSize) do: [:n | booleans pop ] ].
			bool ]
		ifNone: [ node := nil ].
	^ node
]

{ #category : #testing }
GPLeafNode >> isLeafNode [ 		
	^ true
]

{ #category : #initialization }
GPLeafNode >> printOn: aStream [

	aStream nextPutAll: id
]
