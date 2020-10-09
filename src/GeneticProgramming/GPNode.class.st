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
GPNode >> expandChildrenGiven: configuration grammar: grammar depth: depth and: booleans [

	 | resultNode |
	 resultNode := self deepCopy.
	 children doWithIndex: [ :child :index | 
		 | newChild |
		 newChild := (grammar nodeOf: child id)
			             expandGiven: configuration
			             grammar: grammar
			             depth: depth - 1
			             and: booleans.
		 newChild
			 ifNil: [ ^ nil ]
			 ifNotNil: [ resultNode children at: index put: newChild ] ].
	 ^ resultNode
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

	 | result |
	 result := (self selectedOptionNode: (grammar optionsOf: id) given: configuration) deepCopy.
	 result children doWithIndex: [ :child :index | 
		 result children
			 at: index
			 put: (grammar expandFrom: child id given: configuration) ].
	 ^ result
]

{ #category : #'collecting leaves' }
GPNode >> expandGiven: configuration grammar: grammar depth: depth and: booleans [

	 | node |
	 node := nil.
	 depth > 1 ifTrue: [ 
		 | yetSelected randomIndexes optionIndex options |
		 options := grammar optionsOf: self id.
		 randomIndexes := GPRandom instance shuffleElementsOf:
			                  (1 to: options size) asArray.
		 yetSelected := true.
		 optionIndex := 1.
		 [ yetSelected and: [ optionIndex <= randomIndexes size ] ] 
			 whileTrue: [ 
				 node := (options at: (randomIndexes at: optionIndex))
					         expandChildrenGiven: configuration
					         grammar: grammar
					         depth: depth
					         and: booleans.
				 yetSelected := (node isNotNil and: [ 
					                 booleans
						                 inject: false
						                 into: [ :b :e | e or: [ b ] ] ]) not.
				 optionIndex := optionIndex + 1 ] ].
	 ^ node
]

{ #category : #'collecting leaves' }
GPNode >> selectedOptionNode: options given: configuration [

	 ^ options at:
		   (GPRandom instance selectRandomlyGivenProbabilities: (self
				     collectOptions: (1 to: options size)
				     with: (configuration optionWeightsOf: id)))
]
