Class {
	#name : #GPNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'instance creation' }
GPNode class >> children: someNodes [
	^ self new children: someNodes
]

{ #category : #operations }
GPNode >> deepCopy [

	| c |
	c := super deepCopy
		     evaluationBlock: evaluationBlock;
		     printBlock: printBlock.
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
GPNode >> expandChildrenGiven: grammar [

	| resultNode |
	self children size == 1 ifTrue: [ 
		^ (grammar nodeOf: self children first) expandGiven: grammar ].
	
	resultNode := self newNode: grammar.
	children doWithIndex: [ :child :index | 
		| newChild |
		newChild := (grammar nodeOf: child) expandGiven: grammar.
		newChild
			ifNil: [ ^ nil ]
			ifNotNil: [ resultNode children at: index put: newChild ] ].
	^ resultNode
]

{ #category : #'collecting leaves' }
GPNode >> expandChildrenGiven: grammar depth: anInteger and: booleans [

	| resultNode |
	self children size == 1 ifTrue: [ 
		^ (grammar nodeOf: self children first)
			  expandGiven: grammar
			  depth: anInteger
			  and: booleans ].
	anInteger > 1 ifTrue: [ 
		resultNode := self newNode: grammar with: anInteger.
		children doWithIndex: [ :child :index | 
			| newChild |
			newChild := (grammar nodeOf: child)
				            expandGiven: grammar
				            depth: anInteger - 1
				            and: booleans.
			newChild
				ifNil: [ ^ nil ]
				ifNotNil: [ resultNode children at: index put: newChild ] ] ].
	^ resultNode
]

{ #category : #'collecting leaves' }
GPNode >> expandGiven: grammar [


	^ (grammar randomlySelectOption: id) expandChildrenGiven:
		        grammar.

	"| result |
	result := (GPRandom instance selectRandomly: (grammar optionsOf: id)) 
		          newNode: grammar.
	result number: grammar nodeNumber.
	result children doWithIndex: [ :child :index | 
		result children at: index put: (grammar expandFrom: child) ].
	^ result"
]

{ #category : #'collecting leaves' }
GPNode >> expandGiven: grammar depth: anInteger and: booleans [

	| node options |
	node := nil.
	options := grammar randomOptions: id.
	options
		detect: [ :option | 
			node := option
				        expandChildrenGiven: grammar
				        depth: anInteger
				        and: booleans.
			node isNotNil and: [ 
				booleans inject: false into: [ :b :e | e or: [ b ] ] ] ]
		ifNone: [  ].
	^ node
]

{ #category : #initialization }
GPNode >> printOn: aStream [

	aStream nextPut: $(.
	children do: [ :child | 
		child printOn: aStream.
		aStream	nextPut: Character space ].
	aStream nextPut: $)
]
