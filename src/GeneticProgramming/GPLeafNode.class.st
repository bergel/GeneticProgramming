Class {
	#name : #GPLeafNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #testing }
GPLeafNode >> isLeafNode [ 		
	^ true
]

{ #category : #initialization }
GPLeafNode >> printOn: aStream [

	aStream nextPutAll: (id ifNil: [ nodeValue asString ] ifNotNil: [ id ])
]
