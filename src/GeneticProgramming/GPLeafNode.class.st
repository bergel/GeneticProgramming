Class {
	#name : #GPLeafNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #operations }
GPLeafNode >> atIndex: index put: anotherNode [
	^ anotherNode isLeafNode ifTrue: [ anotherNode ] ifFalse: [ self ]
]

{ #category : #copying }
GPLeafNode >> deepCopy [
	| newNode |
	newNode := super deepCopy.
	newNode evaluationBlock: self evaluationBlock;
	printBlock: self printBlock.
	^ newNode
]

{ #category : #'public access' }
GPLeafNode >> evaluate: grammar [

	 ^ GPRandom instance randomlySelect: (grammar optionsOf: self id)
]

{ #category : #'public access' }
GPLeafNode >> evaluate: grammar given: configuration [

	^ (self selectedOptionNode: (grammar optionsOf: id) given: configuration) deepCopy
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandChildrenGiven: grammar and: optionKey [
	^ self expandGiven: grammar
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: context [

	^ self newNode: context 
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: grammar depth: anInteger and: booleans [

	booleans add: anInteger == 1.
	^ self newNode: grammar with: anInteger
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
