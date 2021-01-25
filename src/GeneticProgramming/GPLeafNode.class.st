Class {
	#name : #GPLeafNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

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
	"to remove"
	| node options  |
	anInteger < 1 ifTrue: [ booleans push: false. ^ nil ].
	options := grammar nodeOptionsOf: id.
	(options isEmpty or: [ anInteger = 1 or: [ methodName = #grow ] ]) ifTrue: [ ^ self expandGiven: grammar depth: anInteger and: booleans ].
	node := nil.
	options := grammar shuffle: (options).
	options
		detect: [ :option | | bool prevSize size |
			prevSize := booleans size.
			node := option isSymbol
				ifTrue: [ (grammar nodeOf: option) expandGiven: grammar depth: anInteger - 1 method: methodName and: booleans ]
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

	aStream nextPutAll: (id ifNil: [ nodeValue asString ] ifNotNil: [ id ])
]
