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
GPMessageNode >> expandGiven: configuration grammar: grammar depth: depth and: booleans [

	^ self newNode: grammar
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandReplacingGiven: visitor and: grammar [

	| result |
	result := self newNode: grammar.
	result value: (grammar randomlySelectOption: id).
	^ result
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandReplacingGiven: visitor grammar: grammar depth: depth and: booleans [

	| result |
	result := self newNode: grammar.
	result value: (grammar randomlySelectOption: id given: visitor configuration).
	^ result
]

{ #category : #initialization }
GPMessageNode >> print [
	^ id
]

{ #category : #'public access' }
GPMessageNode >> replaceWithValueFrom: visitor [

	^ GPRandom instance randomlySelect:
		  (visitor selectOption: self id)
	"GPRandom instance selectRandomly: (grammar optionsOf: self id)"
]
