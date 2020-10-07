Class {
	#name : #GPNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'instance creation' }
GPNode class >> children: someNodes [
	^ self new children: someNodes
]

{ #category : #operations }
GPNode >> deepCopy [

	 | c |
	 c := super deepCopy
		      type: self type;
		      evaluationBlock: evaluationBlock;
		      printBlock: printBlock.
	 self children do: [ :child | c addChild: child deepCopy ].
	 ^ c
]

{ #category : #'public access' }
GPNode >> evaluate: grammar [

	 ^ children size == 1
		   ifTrue: [ children first evaluate: grammar ]
		   ifFalse: [ 
			   (children first evaluate: grammar)
				   perform: (children second evaluate: grammar)
				   withEnoughArguments:
				   ((children copyFrom: 3 to: children size) collect: [ :child | 
					    child evaluate: grammar ]) ]
]

{ #category : #'public access' }
GPNode >> evaluate: grammar given: configuration [

	 ^ children size == 1
		   ifTrue: [ children first evaluate: grammar given: configuration ]
		   ifFalse: [ 
			   (children first evaluate: grammar given: configuration)
				   perform: (children second evaluate: grammar given: configuration)
				   withEnoughArguments:
					   ((children copyFrom: 3 to: children size) collect: [ :child | 
						    child evaluate: grammar given: configuration ]) ]
]

{ #category : #'collecting leaves' }
GPNode >> expandGiven: grammar [

	 | result |
	 result := (GPRandom instance selectRandomly: (grammar optionsOf: id))
		           deepCopy.
	 result children doWithIndex: [ :child :index | 
		 result children at: index put: (grammar expandFrom: child id) ].
	 ^ result
]

{ #category : #'collecting leaves' }
GPNode >> expandGiven: grammar and: configuration [

	 | result options |
	options := grammar optionsOf: id.
	 result := (options at: (GPRandom instance selectRandomlyGivenProbabilities:
		            (self
			             collectOptions: (1 to: options size)
			             with: (configuration optionWeightsOf: id)))) deepCopy.
	 result children doWithIndex: [ :child :index | 
		 result children
			 at: index
			 put: (grammar expandFrom: child id given: configuration) ].
	 ^ result
]
