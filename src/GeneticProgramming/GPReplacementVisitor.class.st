Class {
	#name : #GPReplacementVisitor,
	#superclass : #Object,
	#instVars : [
		'lastValue',
		'nodes'
	],
	#category : #'GeneticProgramming-Visitor'
}

{ #category : #adding }
GPReplacementVisitor >> addNode: aNode [
	nodes push: aNode
]

{ #category : #initialization }
GPReplacementVisitor >> initialize [

	nodes := Stack new
]

{ #category : #accessing }
GPReplacementVisitor >> lastValue [ 	
	^ lastValue 
]

{ #category : #'as yet unclassified' }
GPReplacementVisitor >> numberOfArguments: string [

	| number |
	number := string occurrencesOf: $:.
	number > 0 ifFalse: [ 
		(string endsWithAnyOf:
			 (Character specialCharacters asArray collect: [ :c | c asString ])) 
			ifTrue: [ number := 1 ] ].
	^ number
]

{ #category : #visiting }
GPReplacementVisitor >> visitArgumentNode: argumentNode [
	^ self visitVariableNode: argumentNode 
]

{ #category : #visiting }
GPReplacementVisitor >> visitArgumentNodes: nodeCollection [
	^ nodeCollection do: [ :n | self visitArgumentNode: n ]
]

{ #category : #visiting }
GPReplacementVisitor >> visitAssignmentNode: assignmentNode [

	| children |
	nodes ifEmpty: [ ^ self ].
	children := nodes pop children.
	assignmentNode variable: (children first generateAST: self).
	assignmentNode value: (children second generateAST: self).
	lastValue := assignmentNode
]

{ #category : #visiting }
GPReplacementVisitor >> visitBlockNode: blockNode [
	| children child |
	nodes ifEmpty: [ ^ self ].
	children := nodes pop children.
	children size > 1 
		ifTrue: [ child := children first.
			child isCollectionNode ifFalse: [ child := GPCollectionNode transform: child ].
			blockNode arguments: (child generateAST: self).
			child := children second ]
		ifFalse: [ child := children first. ].
	blockNode body: (child generateAST: self) asSequenceNode.	
	lastValue := blockNode.
	"self visitArgumentNodes: blockNode arguments.
	self visitNode: blockNode body"
]

{ #category : #visiting }
GPReplacementVisitor >> visitLiteralNode: literal [

	| node |
	node := nodes pop.
	lastValue := literal class value: node nodeValue
]

{ #category : #visiting }
GPReplacementVisitor >> visitMessageNode: messageNode [

	| children symbol child |
	nodes ifEmpty: [ ^ self ].
	children := nodes pop children.
	messageNode receiver: (children first generateAST: self).
	symbol := children second generateAST: self.
	messageNode selector: symbol.
	[child := children third.
	"child type = RBBlockNode ifTrue: [ self halt ]."
	child isCollectionNode ifFalse: [ 
		child isSelectorNode ifTrue: [ child := child convertToLeafNode ].
		child := GPCollectionNode transform: child ].
	messageNode arguments: (child
			 children collect: [ :ch | ch generateAST: self ]) ] on: SubscriptOutOfBounds do: [ messageNode arguments: OrderedCollection new ].
	lastValue := messageNode
]

{ #category : #visiting }
GPReplacementVisitor >> visitMethodNode: methodNode [

	"| children |
	nodes isEmpty ifTrue: [ ^ self ].
	children := nodes pop children.
	methodNode selector: (children first replaceWithValueFrom: self).
	methodNode body: lastValue.
	methodNode arguments: lastValue"
]

{ #category : #visiting }
GPReplacementVisitor >> visitNode: node [

	node acceptVisitor: self.
	lastValue := node
]

{ #category : #visiting }
GPReplacementVisitor >> visitSequenceNode: sequenceNode [
	| children |
	nodes ifEmpty: [ ^ self ].
	children := nodes pop children.
	sequenceNode 
		temporaries: OrderedCollection new;
		statements: (children collect: [ :ch | ch generateAST: self ]).
	lastValue := sequenceNode 
	"| children |
	nodes isEmpty ifTrue: [ ^ self ].
	children := nodes pop children.
	children first children do: [ :child | 
		self visitNode: (child replaceWithValueFrom: self).
		sequenceNode addTemporaryNamed: lastValue name ].
	sequenceNode statements:
		(children second children collect: [ :child | 
			 self visitNode: (child replaceWithValueFrom: self).
			 lastValue ])"
]

{ #category : #visiting }
GPReplacementVisitor >> visitVariableNode: variable [

	| node |
	node := nodes pop.
	lastValue := variable name: node nodeValue
		            " (self randomlySelectOption: node id)"
]
