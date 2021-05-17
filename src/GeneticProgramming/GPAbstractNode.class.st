Class {
	#name : #GPAbstractNode,
	#superclass : #Object,
	#instVars : [
		'id',
		'children',
		'type',
		'evaluationBlock',
		'printBlock',
		'depth',
		'fitness',
		'nodeValue'
	],
	#category : #'GeneticProgramming-Core'
}

{ #category : #accessing }
GPAbstractNode >> addChild: aNode [
	children add: aNode
]

{ #category : #accessing }
GPAbstractNode >> allLeaves [
	| c |
	c := OrderedCollection new.
	self allLeaves: c.
	^ c
]

{ #category : #accessing }
GPAbstractNode >> allLeaves: collection [
	"Private usage"
	children do: [ :c |
		c isLeaf 
			ifTrue: [ collection add: c ]
			ifFalse: [ c allLeaves: collection ] ]
]

{ #category : #accessing }
GPAbstractNode >> ast [
	^ self generateAST: GPReplacementVisitor new
]

{ #category : #accessing }
GPAbstractNode >> atIndex: anIndex [
	^ self withAllChildren at: anIndex
]

{ #category : #operations }
GPAbstractNode >> atIndex: index put: anotherNode [
	| i |
	index < 1 ifTrue: [ ^ self ].
	i := index.
	i := i - 1.
	self children doWithIndex: [ :child :ii |
		i = 1 ifTrue: [  self children at: ii put: anotherNode. ^ self ].
		child atIndex: i put: anotherNode.
		i := i - 1. ].
	
]

{ #category : #accessing }
GPAbstractNode >> children [
	^ children
]

{ #category : #accessing }
GPAbstractNode >> children: someNodes [
	children := someNodes
]

{ #category : #copying }
GPAbstractNode >> deepCopy [

	^ self class new id: id;
		type: type;
		depth: depth;
		evaluationBlock: evaluationBlock;
		printBlock: printBlock;
		nodeValue: nodeValue deepCopy
]

{ #category : #accessing }
GPAbstractNode >> depth [ 
	^ depth
]

{ #category : #accessing }
GPAbstractNode >> depth: aNumber [
	depth := aNumber
]

{ #category : #initialization }
GPAbstractNode >> evaluate [
	^ self evaluateUsing: nil
]

{ #category : #initialization }
GPAbstractNode >> evaluateUsing: context [

	^ evaluationBlock value: self value: context
]

{ #category : #'as yet unclassified' }
GPAbstractNode >> evaluateWith: orderedDictionary [
	| block |
	block := (RBBlockNode 
		arguments: (orderedDictionary keys collect: [:k | RBVariableNode named: k ])
		body: (RBSequenceNode new statements: (OrderedCollection with: self evaluate))) evaluate.
	^ block 
			valueWithPossibleArgs: orderedDictionary values
]

{ #category : #accessing }
GPAbstractNode >> evaluationBlock [
	^ evaluationBlock
]

{ #category : #accessing }
GPAbstractNode >> evaluationBlock: aOneArgBlock [
	"Take the children as argument"
	evaluationBlock := aOneArgBlock
]

{ #category : #accessing }
GPAbstractNode >> first [
	^ children first
]

{ #category : #accessing }
GPAbstractNode >> fitness [
	^ fitness 
]

{ #category : #accessing }
GPAbstractNode >> fitness: aNumber [
	fitness := aNumber 
]

{ #category : #translating }
GPAbstractNode >> generateAST: visitor [

	| inst |
	type ifNil: [ ^ nodeValue ].
	visitor addNode: self.
	inst := type new.
	inst acceptVisitor: visitor.
	^ visitor lastValue
]

{ #category : #accessing }
GPAbstractNode >> id [
	^ id
]

{ #category : #accessing }
GPAbstractNode >> id: anObject [
	id := anObject
]

{ #category : #operations }
GPAbstractNode >> indexesOf: nodeId on: childIds [
	| indexes |
	indexes := OrderedCollection new.
	childIds doWithIndex: [ :childId :index | 
		childId == nodeId ifTrue: [ indexes add: index ] ].
	^ indexes 
]

{ #category : #initialization }
GPAbstractNode >> initialize [

	super initialize.
	children := OrderedCollection new.
	depth := 0
]

{ #category : #testing }
GPAbstractNode >> isCollectionNode [

	^ false
]

{ #category : #testing }
GPAbstractNode >> isComplexNode [

	^ false
]

{ #category : #testing }
GPAbstractNode >> isLeaf [
	^ children isEmpty
]

{ #category : #testing }
GPAbstractNode >> isLeafNode [
	^ false
]

{ #category : #testing }
GPAbstractNode >> isSelectorNode [

	^ false
]

{ #category : #accessing }
GPAbstractNode >> nodeValue [

	children ifNotEmpty: [ 
		nodeValue := [children collect: [ :child | child nodeValue ]] on: MessageNotUnderstood do: [ nil ]
	].
	^ nodeValue
]

{ #category : #accessing }
GPAbstractNode >> nodeValue: anObject [

	nodeValue := anObject
]

{ #category : #metrics }
GPAbstractNode >> numberOfNodes [
	^ self withAllChildren size
]

{ #category : #initialization }
GPAbstractNode >> print [

	"^ self subclassResponsibility"
	^ self printUsing: nil
]

{ #category : #accessing }
GPAbstractNode >> printBlock [
	^ printBlock
]

{ #category : #accessing }
GPAbstractNode >> printBlock: anObject [
	printBlock := anObject
]

{ #category : #printing }
GPAbstractNode >> printOn: aStream [

	 "super printOn: aStream."
	 aStream nextPutAll: self id
]

{ #category : #initialization }
GPAbstractNode >> printUsing: context [
	^ printBlock value: self value: context "children value: context"
]

{ #category : #accessing }
GPAbstractNode >> replaceBy: anotherNode [
	self assert: anotherNode class == self class.
	self id: anotherNode id;
		"type: anotherNode type;"
		nodeValue: anotherNode nodeValue;
		printBlock: anotherNode printBlock;
		evaluationBlock: anotherNode evaluationBlock;
		children: anotherNode children 
]

{ #category : #accessing }
GPAbstractNode >> second [
	^ children second
]

{ #category : #accessing }
GPAbstractNode >> type [
	^ type
]

{ #category : #accessing }
GPAbstractNode >> type: aSymbol [
	type := aSymbol
]

{ #category : #accessing }
GPAbstractNode >> withAllChildren [
	| c |
	c := OrderedCollection new.
	c add: self.
	self withAllChildren: c.
	^ c
]

{ #category : #accessing }
GPAbstractNode >> withAllChildren: collection [
	"Private usage"
	children do: [ :c |
		collection add: c.
		c withAllChildren: collection ]
]
