Class {
	#name : #GPMessageNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'public access' }
GPMessageNode >> evaluate: grammar [

	 ^ GPRandom instance selectRandomly: (grammar optionsOf: self id)
]

{ #category : #'public access' }
GPMessageNode >> evaluate: grammar given: configuration [

	 | options |
	 options := grammar optionsOf: id.
	 ^ (options at:
		    (GPRandom instance selectRandomlyGivenProbabilities: (self
				      collectOptions: (1 to: options size)
				      with: (configuration optionWeightsOf: id)))) deepCopy
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandGiven: context [

	 ^ self
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandGiven: grammas and: configuration [

	 ^ self
]

{ #category : #'collecting leaves' }
GPMessageNode >> expandGiven: configuration grammar: grammar depth: depth and: booleans [

	 ^ self
]

{ #category : #'public access' }
GPMessageNode >> replaceWithValueFrom: visitor [

	^ GPRandom instance selectRandomly:
		  (visitor selectOption: self id)
	"GPRandom instance selectRandomly: (grammar optionsOf: self id)"
]
