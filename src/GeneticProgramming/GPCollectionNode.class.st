Class {
	#name : #GPCollectionNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #accessing }
GPCollectionNode class >> transform: node [

	^ self new nodeChildren: (Array with: node)
]

{ #category : #comparing }
GPCollectionNode >> = other [

	^ super = other and: [ "]"
		  id == other id and: [ 
			  nodeChildren size == other nodeChildren size and: [ "and: [ depth == other depth "
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
	self nodeChildren do: [ :child | c addChild: child deepCopy ].
	^ c
]

{ #category : #translating }
GPCollectionNode >> generateAST: visitor [

	^ nodeChildren collect: [ :child | child generateAST: visitor ]
]

{ #category : #testing }
GPCollectionNode >> isCollectionNode [

	^ true
]

{ #category : #accessing }
GPCollectionNode >> nodeValue [

	nodeValue := self nodeChildren collect: [ :ch | ch nodeValue ].
	^ nodeValue
]

{ #category : #printing }
GPCollectionNode >> printOn: aStream [

	[ aStream nextPutAll: self ast formattedCode ] 
		on: Exception 
		do: [ aStream nextPutAll: '#('.
	nodeChildren do: [ :child | 
		child printOn: aStream.
		aStream nextPut: Character space ].
	aStream nextPut: $) ]
]
