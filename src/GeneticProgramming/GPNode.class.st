Class {
	#name : #GPNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'instance creation' }
GPNode class >> children: someNodes [

	^ self new nodeChildren: someNodes
]

{ #category : #'instance creation' }
GPNode class >> nodeChildren: someNodes [

	^ self new nodeChildren: someNodes
]

{ #category : #comparing }
GPNode >> = other [

	^ super = other and: [ "]"
		  id == other id and: [ 
			  nodeChildren size == other nodeChildren size and: [ "and: [ depth = other depth "
				  | index |
				  index := 1.
				  nodeChildren
					  detect: [ :child | 
						  | found |
						  found := child ~= (other nodeChildren at: index).
						  index := index + 1.
						  found ]
					  ifFound: [ :c | false ]
					  ifNone: [ true ] ] ] ]
]

{ #category : #operations }
GPNode >> deepCopy [

	| c |
	c := super deepCopy.
	"evaluationBlock: evaluationBlock;
		     printBlock: printBlock."
	self nodeChildren do: [ :child | c addChild: child deepCopy ].
	^ c
]

{ #category : #testing }
GPNode >> isComplexNode [

	^ true
]

{ #category : #initialization }
GPNode >> printOn: aStream [

	[ aStream nextPutAll: self ast formattedCode ]
		on: Exception
		do: [
	aStream nextPut: $(.
	nodeChildren do: [ :child | 
		child printOn: aStream.
		aStream nextPut: Character space ].
	aStream nextPut: $) ]
]
