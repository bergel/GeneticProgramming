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
GPLeafNode >> expandGiven: context [

	^ self newNode: context 
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandGiven: configuration grammar: grammar depth: depth and: booleans [

	booleans add: depth == 1.
	^ self newNode: grammar
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandReplacingGiven: visitor and: grammar [

	| result |
	result := self newNode: grammar.
	visitor addNode: self.
	type ifNotNil: [ 
		| inst |
		inst := type new.
		inst acceptVisitor: visitor.
		result value: visitor lastValue ].
	^ result
]

{ #category : #'collecting leaves' }
GPLeafNode >> expandReplacingGiven: visitor grammar: grammar depth: depth and: booleans [

	| result |
	booleans add: depth == 1.
	result := self newNode: grammar.
	visitor addNode: self.
	type ifNotNil: [ 
		| inst |
		inst := type new.
		inst acceptVisitor: visitor.
		result value: visitor lastValue ].
	^ result
]

{ #category : #initialization }
GPLeafNode >> print [
	^ id
]

{ #category : #'public access' }
GPLeafNode >> replaceWithValueFrom: visitor [

	"grammar"

	^ GPRandom instance randomlySelect:
		  (visitor selectOption: self id)
	"^ GPRandom instance selectRandomly: (grammar optionsOf: self id)"
]
