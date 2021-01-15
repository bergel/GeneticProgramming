Class {
	#name : #GPMessageNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'public access' }
GPMessageNode >> evaluate: grammar [

	 ^ self nodeValue "GPRandom instance randomlySelect: (grammar optionsOf: self id)"
]

{ #category : #'public access' }
GPMessageNode >> evaluate: grammar given: configuration [
	
	^ self evaluate: grammar "(self selectedOptionNode: (grammar optionsOf: id) given: configuration) deepCopy"
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandGiven: context [

	^ self expandGiven: context depth: 1 method: nil and: #()
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandGiven: grammar depth: anInteger method: methodName and: booleans [
	| node |
	node := self newNode: grammar with: anInteger.
	node nodeValue: (self selectOption: grammar).
	^ node
]

{ #category : #translating }
GPMessageNode >> generateAST: visitor [

	^ nodeValue "visitor randomlySelectOption: id"
]

{ #category : #initialization }
GPMessageNode >> initialize [ 
	super initialize.
	printBlock := [ :n :ctx | nodeValue ]
]

{ #category : #testing }
GPMessageNode >> isMessageNode [

	^ true
]

{ #category : #initialization }
GPMessageNode >> printOn: aStream [

	aStream nextPutAll: id
]
