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
		     "evaluationBlock: evaluationBlock;
		     printBlock: printBlock.".
	self children do: [ :child | c addChild: child deepCopy ].
	^ c
]

{ #category : #testing }
GPNode >> isComplexNode [

	^ true
]

{ #category : #initialization }
GPNode >> printOn: aStream [

	aStream nextPut: $(.
	children do: [ :child | 
		child printOn: aStream.
		aStream	nextPut: Character space ].
	aStream nextPut: $)
]
