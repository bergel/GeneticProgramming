Class {
	#name : #GPLeafNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'public access' }
GPLeafNode >> evaluate: grammar [

	 ^ GPRandom instance randomlySelect: (grammar optionsOf: self id)
]

{ #category : #'public access' }
GPLeafNode >> evaluate: grammar given: configuration [

	^ (self selectedOptionNode: (grammar optionsOf: id) given: configuration) deepCopy
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandChildrenGiven: grammar and: optionKey [
	^ self expandGiven: grammar
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: context [

	^ self newNode: context 
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: grammar depth: anInteger and: booleans [

	booleans add: anInteger == 1.
	^ self newNode: grammar with: anInteger
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: grammar depth: anInteger method: methodName and: booleans [

	^ self expandGiven: grammar depth: anInteger and: booleans
]

{ #category : #testing }
GPLeafNode >> isLeafNode [ 		
	^ true
]

{ #category : #initialization }
GPLeafNode >> printOn: aStream [

	aStream nextPutAll: id
]
