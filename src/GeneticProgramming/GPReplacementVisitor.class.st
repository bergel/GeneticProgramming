Class {
	#name : #GPReplacementVisitor,
	#superclass : #Object,
	#instVars : [
		'values',
		'lastValue',
		'grammar',
		'nodes',
		'configuration'
	],
	#category : #'GeneticProgramming-Visitor'
}

{ #category : #adding }
GPReplacementVisitor >> addNode: aNode [
	nodes push: aNode
]

{ #category : #'as yet unclassified' }
GPReplacementVisitor >> getNumberOfArguments: string [

	| number |
	number := string occurrencesOf: $:.
	number > 0 ifFalse: [ 
		(string endsWithAnyOf:
			 (Character specialCharacters asArray collect: [ :c | c asString ])) 
			ifTrue: [ number := 1 ] ].
	^ number
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
GPReplacementVisitor >> randomlySelectOption: symbol [

	^ grammar randomlySelectOption: symbol "given: configuration"
]

{ #category : #'as yet unclassified' }
GPReplacementVisitor >> selectOption: symbol [
	^ grammar optionsOf: symbol
]

{ #category : #accessing }
GPReplacementVisitor >> values: collection [
	values := collection
]

{ #category : #visiting }
GPReplacementVisitor >> visitAssignmentNode: assignmentNode [

	| astNode child ids collection |
	nodes isEmpty ifTrue: [ ^ self ].
	astNode := nodes pop.
	ids := astNode children.
	collection := OrderedCollection new.
	child := (grammar nodeOf: ids first)
		         expandReplacingGiven: self
		         and: grammar.

	assignmentNode variable: child value.
	collection add: child.
	child := (grammar nodeOf: ids second)
		         expandReplacingGiven: self
		         and: grammar.
	assignmentNode value: child value.
	collection add: child.
	astNode children: collection.
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

	| astNode child ids collection |
	nodes isEmpty ifTrue: [ ^ self ].
	astNode := nodes pop.
	ids := astNode children.
	collection := OrderedCollection new.

	child := (grammar nodeOf: ids first)
		         expandReplacingGiven: self
		         and: grammar.
	messageNode receiver: child value.
	collection add: child.

	child := (grammar nodeOf: ids second)
		         expandReplacingGiven: self
		         and: grammar.
	messageNode selector: child value.
	collection add: child.

	child := (grammar nodeOf: ids third)
		         size: (self getNumberOfArguments: child value);
		         expandReplacingGiven: self and: grammar.
	messageNode arguments: child value.
	collection add: child.
	
	astNode children: collection.
	lastValue := messageNode
]

{ #category : #visiting }
GPReplacementVisitor >> visitMethodNode: methodNode [

	| children |
	nodes isEmpty ifTrue: [ ^ self ].
	children := nodes pop children.
	methodNode selector: (children first replaceWithValueFrom: self).
	self visitNode: (children second replaceWithValueFrom: self).
	methodNode body: lastValue.
	self visitNode: (children third replaceWithValueFrom: self).
	methodNode arguments: lastValue
]

{ #category : #visiting }
GPReplacementVisitor >> visitNode: node [

	node acceptVisitor: self.
	lastValue := node
]

{ #category : #visiting }
GPReplacementVisitor >> visitSequenceNode: sequenceNode [

	| children |
	nodes isEmpty ifTrue: [ ^ self ].
	children := nodes pop children.
	"self visitNode: (children first  replaceWithValueFrom: self)."
	children first children do: [ :child | 
		self visitNode: (child replaceWithValueFrom: self).
		sequenceNode addTemporaryNamed: lastValue name ].
	"sequenceNode temporaries: lastValue."
	sequenceNode statements: (children second children collect: [ :child | 
		self visitNode: (child replaceWithValueFrom: self).
		lastValue ])
	"self visitNode: (children second replaceWithValueFrom: self).
	sequenceNode statements: lastValue"
]

{ #category : #visiting }
GPReplacementVisitor >> visitVariableNode: variable [

	| node |
	node := nodes pop.
	lastValue := variable name:
		             (self randomlySelectOption: node id)
]
