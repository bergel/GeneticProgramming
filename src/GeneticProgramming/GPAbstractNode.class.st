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
		'idNumber',
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

{ #category : #operations }
GPAbstractNode >> crossOverGiven: anotherNode and: random [
	| copy ids childIds childNodes |
	copy := self deepCopy.
	ids := copy children collect: #id.
	childNodes := anotherNode withAllChildren.
	childIds := random shuffleElementsOf: (childNodes collect: #id).
	(ids includesAny: childIds) 
		ifFalse: [ copy children do: [ :child | child crossOverGiven: anotherNode and: random ] ]
		ifTrue: [ | index tree |
			index := ids indexOfAnyOf: childIds.
			tree := copy children at: index.
			copy children at: index put: (childNodes at: ((childNodes collect: #id) indexOf: tree id)) deepCopy ]	.
	^ copy
	
]

{ #category : #operations }
GPAbstractNode >> crossOverWith: anotherNode [

	"This method should be called with two root nodes"
	"^ self
		  crossOverWith: anotherNode
		  at: (GPRandom instance randomNumber: self numberOfNodes - 1) + 1
		  at:
			  (GPRandom instance randomNumber: anotherNode numberOfNodes - 1)
				   + 1"
	^ self crossOverWith: anotherNode using: GPRandom instance
]

{ #category : #operations }
GPAbstractNode >> crossOverWith: anotherNode at: index1 at: index2 [
	"Return an offspring"
	| copy |
	copy := self deepCopy.
	copy atIndex: index1 put: (anotherNode atIndex: index2) deepCopy.
	^ copy
]

{ #category : #operations }
GPAbstractNode >> crossOverWith: anotherNode using: random [

	"This method should be called with two root nodes"

	^ (self children collect: #id) asSet size = 1 
		ifTrue: [ self crossOverWith: anotherNode 
			at: ([ (random randomNumber: self numberOfNodes - 1) ] on: Error do: [ 0 ]) + 1
			at: ( [random randomNumber: anotherNode numberOfNodes - 1] on: Error do: [ 0 ] ) + 1 ]
		ifFalse: [ self crossOverGiven: anotherNode and: random ]
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

{ #category : #accessing }
GPAbstractNode >> idNumber [

	^ idNumber
]

{ #category : #accessing }
GPAbstractNode >> idNumber: aNumber [

	idNumber := aNumber
]

{ #category : #initialization }
GPAbstractNode >> initialize [

	super initialize.
	children := OrderedCollection new.
	idNumber := 0.
	depth := 0
	"printBlock := [ :c | 
	              | t |
	              t := c inject: '(' into: [ :sum :el | sum , el print ].
	              t , ')' ]"
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

{ #category : #'instance creation' }
GPAbstractNode >> newNode: integer [

	| node |
	node := self deepCopy.
	node idNumber: integer.
	^ node
]

{ #category : #'instance creation' }
GPAbstractNode >> newNode: grammar with: aNumber [

	| node |
	node := self deepCopy.
	node
		idNumber: grammar nodeNumber;
		depth: aNumber.
	^ node
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
GPAbstractNode >> second [
	^ children second
]

{ #category : #visualization }
GPAbstractNode >> shapes [

	^ (self withAllChildren collect: [ :child | 
		   RSComposite new
			   model: child;
			   addShape: (RSEllipse new
					    extent: 20 @ 20;
					    color: (Color r: 0.5298142717497556 g: 0.8074291300097751 b: 0.9804496578690127);
					    border: (RSBorder new
							     color: (Color
									      r: 0.2316715542521994
									      g: 0.5141739980449658
									      b: 0.7409579667644184);
							     yourself);
					    @ RSDraggable);
			   addShape: (RSLabel new
					    text: child id;
					    color: Color black;
					    bold;
					    fontSize: 2);
			   padding: 10;
			   yourself ]) asOrderedCollection
]

{ #category : #accessing }
GPAbstractNode >> type [
	^ type
]

{ #category : #accessing }
GPAbstractNode >> type: aSymbol [
	type := aSymbol
]

{ #category : #visualization }
GPAbstractNode >> visualize [
	 | canvas eb |
			  canvas := RSCanvas new.
			  canvas addAll: self shapes.
			  eb := RSEdgeBuilder line
				        color: (Color
						         r: 0.2316715542521994
						         g: 0.5141739980449658
						         b: 0.7409579667644184);
				        canvas: canvas;
				        connectToAll: #children.
			  canvas edges pushBack.
			  RSTreeLayout new
				  verticalGap: 10;
				  on: canvas nodes.
			  canvas @ RSCanvasController.
	^ canvas
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
