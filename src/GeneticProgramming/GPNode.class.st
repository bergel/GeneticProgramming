Class {
	#name : #GPNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'instance creation' }
GPNode class >> children: someNodes [
	^ self new children: someNodes
]

{ #category : #comparing }
GPNode >> = other [ 
	^ super = other 
		and: [ id == other id 
			and: [ children size == other children size 
				"and: [ depth = other depth "
					and: [ | index |
						index := 1.
						children detect: [ :child | | found |
							found := child ~= (other children at: index).
							index := index + 1.
							found ] 
						ifFound: [ :c | false ] 
						ifNone: [ true ] ] ] ] "]"
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
