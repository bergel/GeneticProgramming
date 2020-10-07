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

	 ^ self
]

{ #category : #'collecting leaves' }
GPLiteralNode >> expandGiven: grammas and: configuration [

	 ^ self
]
