Class {
	#name : #GPAbstractNode,
	#superclass : #Object,
	#instVars : [
		'id',
		'children',
		'type',
		'evaluationBlock',
		'printBlock',
		'value',
		'depth',
		'idNumber',
		'ast'
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
	^ ast
]

{ #category : #accessing }
GPAbstractNode >> ast: anASTNode [
	ast := anASTNode 
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
	(self children collect: #class) asSet size = 1 
		ifFalse: [ | ind |
			ind := 0.
			self children detect: [ :ch | ind := ind + 1.
				ch isKindOf: anotherNode class ] 
			ifFound: [ :ch | self children at: ind put: anotherNode ].
			^ self ] 
		ifTrue: [ 
			self children doWithIndex: [ :child :ii |
				i = 1 ifTrue: [ "| n | 
				n := self children at: ii.
				n isComplexNode ifTrue: [ self children at: ii put: anotherNode ] 
				ifFalse: [self children at: ii put: (n atIndex: i put: anotherNode )]. ^ self "
					self children at: ii put: anotherNode.
					^ self ].
				child atIndex: i put: anotherNode.
				i := i - 1. ] ].
	
]

{ #category : #accessing }
GPAbstractNode >> children [
	^ children
]

{ #category : #accessing }
GPAbstractNode >> children: someNodes [
	children := someNodes
]

{ #category : #'groups collecting' }
GPAbstractNode >> collectOptions: options with: numbers [

	| weights |
	weights := numbers.
	weights size < options size ifTrue: [ 
		weights := (1 to: options size) collect: [ :n | 1 ] ].
	^ (options with: weights collect: [ :opt :w | opt -> w ])
		  asOrderedDictionary
]

{ #category : #operations }
GPAbstractNode >> crossOverWith: anotherNode [

	"This method should be called with two root nodes"

	^ self
		  crossOverWith: anotherNode
		  at: (GPRandom instance randomNumber: self numberOfNodes - 1) + 1
		  at:
			  (GPRandom instance randomNumber: anotherNode numberOfNodes - 1)
				   + 1
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

	^ self
		  crossOverWith: anotherNode
		  at: ([ random nextInteger: self numberOfNodes - 1 ] on: Error do: [ 0 ]) + 1
		  at: ( [random nextInteger: anotherNode numberOfNodes - 1] on: Error do: [ 0 ] ) + 1
]

{ #category : #copying }
GPAbstractNode >> deepCopy [

	^ self class new id: id;
	type: type
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

{ #category : #'public access' }
GPAbstractNode >> evaluate: grammar [

	 ^ self subclassResponsibility
]

{ #category : #'public access' }
GPAbstractNode >> evaluate: grammar given: configuration [

	 ^ self subclassResponsibility
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

{ #category : #'collecting leaves' }
GPAbstractNode >> expandChildrenGiven: grammar and: optionKey [
	^ self subclassResponsibility 
]

{ #category : #'collecting leaves' }
GPAbstractNode >> expandGiven: context [

	^ self subclassResponsibility
]

{ #category : #'collecting leaves' }
GPAbstractNode >> expandGiven: grammar depth: anInteger method: methodName and: booleans [
	^ self subclassResponsibility 
]

{ #category : #accessing }
GPAbstractNode >> first [
	^ children first
]

{ #category : #translating }
GPAbstractNode >> generateAST: visitor [

	| inst |
	type ifNil: [ ^ nil ].
	visitor addNode: self.
	inst := type new.
	inst acceptVisitor: visitor.
	^ visitor lastValue
]

{ #category : #visualization }
GPAbstractNode >> gtInspectorViewIn: composite [

	<gtInspectorPresentationOrder: -1>
	^ composite roassal3
		  title: [ 'MetaDescription Tree' ];
		  initializeCanvas: [ 
			  | canvas eb |
			  canvas := RSCanvas new.
			  canvas addAll: (self shapes).
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
			  canvas @ RSCanvasController ]
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
GPAbstractNode >> idNumber: aNumber [

	idNumber := aNumber
]

{ #category : #initialization }
GPAbstractNode >> initialize [

	super initialize.
	children := OrderedCollection new.
	idNumber := 0.
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
GPAbstractNode >> isMessageNode [

	^ false
]

{ #category : #'as yet unclassified' }
GPAbstractNode >> methodDepthBlock: string [
	| block |
	block := nil.
	string = #full 
		ifTrue: [ block := [ :node :bools | node isNotNil and: [ 
				bools inject: true into: [ :b :e | e and: [ b ] ] ] ] ].
	string = #grow ifTrue: [ block := [ :node :bools | node isNotNil and: [ 
				bools inject: false into: [ :b :e | e or: [ b ] ] ] ] ].
	^ block
]

{ #category : #'instance creation' }
GPAbstractNode >> newNode: grammar [

	| node |
	node := self deepCopy.
	node idNumber: grammar nodeNumber.
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

{ #category : #'collecting leaves' }
GPAbstractNode >> selectedOptionNode: options given: configuration [

	^ options at:
		  (GPRandom instance randomlySelectGivenProbabilities: (self
				    collectOptions: (1 to: options size)
				    with: (configuration optionWeightsOf: id)))
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

{ #category : #accessing }
GPAbstractNode >> value [

	^ value
]

{ #category : #accessing }
GPAbstractNode >> value: anObject [
	value := anObject
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
