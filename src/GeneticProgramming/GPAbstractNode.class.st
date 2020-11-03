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
		'idNumber'
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

{ #category : #'groups collecting' }
GPAbstractNode >> collectOptions: options with: numbers [

	| weights |
	weights := numbers.
	weights size < options size ifTrue: [ 
		weights := (1 to: options size) collect: [ :n | 1 ] ].
	^ (options with: weights collect: [ :opt :w | opt -> w ])
		  asDictionary
]

{ #category : #operations }
GPAbstractNode >> crossOverWith: anotherNode [
	"This method should be called with two root nodes"
	^ self crossOverWith: anotherNode at: (self numberOfNodes - 1) atRandom + 1 at: (anotherNode numberOfNodes - 1) atRandom + 1
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
		at: (random nextInt: self numberOfNodes - 1) + 1
		at: (random nextInt: anotherNode numberOfNodes - 1) + 1
]

{ #category : #copying }
GPAbstractNode >> deepCopy [

	^ self class new id: id;
	type: type
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

	 ^ evaluationBlock value: children value: context "evaluationBlock value: children value: context"
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
GPAbstractNode >> expandGiven: context [

	^ self subclassResponsibility
]

{ #category : #'collecting leaves' }
GPAbstractNode >> expandGiven: grammar depth: aNumber and: booleans [

	^ self subclassResponsibility
]

{ #category : #'collecting leaves' }
GPAbstractNode >> expandReplacingGiven: visitor and: context [

	^ self subclassResponsibility
]

{ #category : #'collecting leaves' }
GPAbstractNode >> expandReplacingGiven: visitor grammar: grammar depth: aNumber and: booleans [

	^ self subclassResponsibility
]

{ #category : #accessing }
GPAbstractNode >> first [
	^ children first
]

{ #category : #visualization }
GPAbstractNode >> gtInspectorViewIn: composite [

	<gtInspectorPresentationOrder: -1>
	| m |
	m := RSMondrian new.
	"m shape circle."
	m nodes: self withAllChildren forEach: [ :n | 
		m shape label color: Color white.
		m nodes: (Array with: n id) ].
	m line
		color: (Color r: 59 / 255 g: 131 / 255 b: 189 / 255);
		width: 0.5;
		connectToAll: #children.
	m layout tree.
	^ m gtInspectorViewIn: composite
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
GPAbstractNode >> isLeaf [
	^ children isEmpty
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

{ #category : #operations }
GPAbstractNode >> replaceWithValueFrom: context [
	^ self subclassResponsibility 
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
