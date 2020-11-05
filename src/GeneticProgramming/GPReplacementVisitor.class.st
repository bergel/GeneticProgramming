Class {
	#name : #GPReplacementVisitor,
	#superclass : #Object,
	#instVars : [
		'lastValue',
		'grammar',
		'nodes'
	],
	#category : #'GeneticProgramming-Visitor'
}

{ #category : #adding }
GPReplacementVisitor >> addNode: aNode [
	nodes push: aNode
]

{ #category : #accessing }
GPReplacementVisitor >> grammar [
	^ grammar
]

{ #category : #accessing }
GPReplacementVisitor >> grammar: aGrammar [
	grammar := aGrammar
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

{ #category : #'as yet unclassified' }
GPReplacementVisitor >> randomlySelectOption: symbol [

	^ grammar randomlySelectOption: symbol
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
GPReplacementVisitor >> visitLiteralNode: literal [

	| node |
	node := nodes pop.
	lastValue := literal class value:
		             (self
			              randomlySelectOption: node id)
]

{ #category : #visiting }
GPReplacementVisitor >> visitMessageNode: messageNode [

	| children symbol child |
	nodes ifEmpty: [ ^ self ].
	children := nodes pop children.
	messageNode receiver: (children first generateAST: self).
	symbol := children second generateAST: self.
	messageNode selector: symbol.
	child := children third.
	child isCollectionNode ifFalse: [ 
		child := GPCollectionNode transform: child ].
	messageNode arguments: (child
			 size: (self numberOfArguments: symbol);
			 generateAST: self).
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
	lastValue := variable name:
		             (self randomlySelectOption: node id)
]
