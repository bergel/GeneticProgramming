Class {
	#name : #GPCollectionNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #accessing }
GPCollectionNode class >> transform: node [
	^ self new children: (Array with: node)
]

{ #category : #accessing }
GPCollectionNode >> ast [ 
	^ RBSequenceNode statements: super ast
]

{ #category : #copying }
GPCollectionNode >> deepCopy [

	| c |
	c := super deepCopy. ";
		     evaluationBlock: evaluationBlock;
		     printBlock: printBlock"
	self children do: [ :child | c addChild: child deepCopy ].
	^ c
]

{ #category : #translating }
GPCollectionNode >> generateAST: visitor [

	^ children collect: [ :child | child generateAST: visitor ]
]

{ #category : #testing }
GPCollectionNode >> isCollectionNode [

	^ true
]

{ #category : #'instance creation' }
GPCollectionNode >> newNode: grammar with: aNumber [
	| node |
	node := self newNode: grammar.
	node idNumber: grammar nodeNumber;
		depth: aNumber.
	^ node
]

{ #category : #accessing }
GPCollectionNode >> nodeValue [
	nodeValue := self children collect: [:ch | ch nodeValue ].
	^ nodeValue 
]

{ #category : #printing }
GPCollectionNode >> printOn: aStream [

	aStream nextPutAll: '#('.
	children do: [ :child | 
		child printOn: aStream.
		aStream nextPut: Character space ].
	aStream nextPut: $)
]
