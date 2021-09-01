Class {
	#name : #GPLeafNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #comparing }
GPLeafNode >> = other [
	^ super = other 
		and: [ id == other id 
			and: [ nodeValue = other nodeValue 
				"and: [ depth == other depth ]" ] ]
]

{ #category : #testing }
GPLeafNode >> isLeafNode [ 		
	^ true
]

{ #category : #initialization }
GPLeafNode >> printOn: aStream [

	[ aStream nextPutAll: self ast formattedCode ]
		on: Exception
		do: [
	aStream nextPutAll:
		(id ifNil: [ nodeValue asString ] ifNotNil: [ id ]) ]
]
