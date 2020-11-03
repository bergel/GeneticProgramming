Class {
	#name : #GPMessageNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'public access' }
GPMessageNode >> evaluate: grammar [

	 ^ GPRandom instance randomlySelect: (grammar optionsOf: self id)
]

{ #category : #'public access' }
GPMessageNode >> evaluate: grammar given: configuration [

	^ (self selectedOptionNode: (grammar optionsOf: id) given: configuration) deepCopy
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandGiven: context [

	^ self newNode: context
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandGiven: grammar depth: anInteger and: booleans [

	^ self newNode: grammar with: anInteger
]

{ #category : #translating }
GPMessageNode >> generateAST: visitor [

	^ visitor randomlySelectOption: id
]

{ #category : #initialization }
GPMessageNode >> printOn: aStream [

	aStream nextPutAll: id
]

{ #category : #'public access' }
GPMessageNode >> replaceWithValueFrom: visitor [

	^ GPRandom instance randomlySelect:
		  (visitor selectOption: self id)
	"GPRandom instance selectRandomly: (grammar optionsOf: self id)"
]
