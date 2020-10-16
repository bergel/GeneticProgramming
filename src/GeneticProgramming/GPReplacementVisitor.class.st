Class {
	#name : #GPReplacementVisitor,
	#superclass : #Object,
	#instVars : [
		'values',
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
GPReplacementVisitor >> grammar: aGrammar [
	grammar := aGrammar
]

{ #category : #initialization }
GPReplacementVisitor >> initialize [

	nodes := Stack new
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

	| astNode |
	nodes isEmpty ifTrue: [ ^ self ].
	astNode := nodes pop.
	self visitNode: (astNode children first replaceWithValueFrom: self). 
	assignmentNode variable: lastValue.
	self visitNode: (astNode children second replaceWithValueFrom: self).
	assignmentNode value: lastValue
]

{ #category : #visiting }
GPReplacementVisitor >> visitLiteralValueNode: literal [

]

{ #category : #visiting }
GPReplacementVisitor >> visitMessageNode: messageNode [

	| astNode |
	nodes isEmpty ifTrue: [ ^ self ].
	astNode := nodes pop.
	self visitNode: (astNode children first replaceWithValueFrom: self).
	messageNode receiver: lastValue.
	messageNode selector:
		(astNode children second replaceWithValueFrom: self).
	self visitNode: (astNode children third replaceWithValueFrom: self).
	messageNode arguments: (Array with: lastValue)
]

{ #category : #visiting }
GPReplacementVisitor >> visitNode: node [

	node acceptVisitor: self.
	lastValue := node
]

{ #category : #visiting }
GPReplacementVisitor >> visitVariableNode: variable [
]
