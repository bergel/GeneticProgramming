Class {
	#name : #GPLiteralNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'public access' }
GPLiteralNode >> evaluate: grammar [

	 ^ GPRandom instance selectRandomly: (grammar optionsOf: self id)
]

{ #category : #'public access' }
GPLiteralNode >> evaluate: grammar given: configuration [

	 | options |
	 options := grammar optionsOf: id.
	 ^ (options at:
		            (GPRandom instance selectRandomlyGivenProbabilities:
			             (self
				              collectOptions: (1 to: options size)
				              with: (configuration optionWeightsOf: id))))
		           deepCopy.
]

{ #category : #'collecting leaves' }
GPLiteralNode >> expandGiven: context [

	^ self newNode: context 
]

{ #category : #'collecting leaves' }
GPLiteralNode >> expandGiven: grammar and: configuration [

	^ self newNode: grammar
]

{ #category : #'collecting leaves' }
GPLiteralNode >> expandGiven: configuration grammar: grammar depth: depth and: booleans [

	booleans add: depth == 1.
	^ self newNode: grammar
]

{ #category : #'public access' }
GPLiteralNode >> replaceWithValueFrom: visitor [

	"grammar"

	^ GPRandom instance selectRandomly:
		  (visitor selectOption: self id)
	"^ GPRandom instance selectRandomly: (grammar optionsOf: self id)"
]
