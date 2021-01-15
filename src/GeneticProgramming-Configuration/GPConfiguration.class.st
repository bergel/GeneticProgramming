Class {
	#name : #GPConfiguration,
	#superclass : #Object,
	#instVars : [
		'random',
		'rulesWeights',
		'optionsWeights',
		'method',
		'depth'
	],
	#category : #'GeneticProgramming-Configuration-Core'
}

{ #category : #adding }
GPConfiguration >> addOptionWeights: numbers forRule: symbol [

	 optionsWeights at: symbol put: numbers
]

{ #category : #adding }
GPConfiguration >> addWeight: number forRule: symbol [

	 rulesWeights at: symbol put: number
]

{ #category : #operations }
GPConfiguration >> createNewIndividual [
	"Return a new individual"
	
	"
	| i b |
	i := GPAritConfiguration new createNewIndividual.
	b := RTMondrian new.
	b shape label text: #type.
	b nodes: i withAllChildren.
	b edges connectToAll: #children.
	b layout tree.
	b
	"
	
	| rootNode |
	rootNode := self newFunction.
	self createNewIndividualRoot: rootNode depth: 3.
	^ rootNode
]

{ #category : #'private-operation' }
GPConfiguration >> createNewIndividualRoot: rootNode depth: depth [
	depth = 1 ifTrue: [ 
		1 to: 2 do: [ :i |
			rootNode addChild: self newTerminal ]. 
		^ self ].
	
	"50% to change a terminal"
	1 to: 2 do: [ :i |
		self randomBoolean
			ifTrue: [ 
				| f |
				f := self newFunction.
				rootNode addChild: f.
				self createNewIndividualRoot: f depth: depth - 1 ]
			ifFalse: [ rootNode addChild: self newTerminal ] ]
]

{ #category : #accessing }
GPConfiguration >> depth [

	^ depth
]

{ #category : #accessing }
GPConfiguration >> depth: anObject [

	depth := anObject
]

{ #category : #operations }
GPConfiguration >> distanceFromSolutionOf: individual [
	"This method has to return a number that describes how close the individual is to the solution.
	If this returns 0, then the individual is a perfect match
	"
	self subclassResponsibility 
]

{ #category : #initialization }
GPConfiguration >> initialize [
	super initialize.
	random := GPRandom instance.
	rulesWeights := Dictionary new.
	optionsWeights := Dictionary new.
	method := #grow
]

{ #category : #accesing }
GPConfiguration >> keysOfRuleWeights [ 
	^ rulesWeights keys
]

{ #category : #accessing }
GPConfiguration >> method [

	^ method
]

{ #category : #accessing }
GPConfiguration >> method: anObject [

	method := anObject
]

{ #category : #operations }
GPConfiguration >> mutate: individual [
	| nodeToMutate source |
	nodeToMutate := self randomElementOf: (individual withAllChildren select: [ :n | n children isEmpty ]).
	source := self newTerminal.
	nodeToMutate evaluationBlock: source evaluationBlock.
	nodeToMutate printBlock: source printBlock.
	nodeToMutate type: source type.
]

{ #category : #hooks }
GPConfiguration >> newFunction [
	"This method has to return a new function"
	self subclassResponsibility 
]

{ #category : #hooks }
GPConfiguration >> newTerminal [
	"This method has to return a new function"
	self subclassResponsibility 
]

{ #category : #hooks }
GPConfiguration >> numberOfGenerations [
	^ 20
]

{ #category : #accesing }
GPConfiguration >> optionWeightsOf: symbol [

	^ optionsWeights at: symbol ifAbsent: [ #(1) ]
]

{ #category : #accessing }
GPConfiguration >> populationSize [
	^ 500
]

{ #category : #accessing }
GPConfiguration >> random [
	^ random
]

{ #category : #'private-random operations' }
GPConfiguration >> randomBoolean [

	^ (random randomNumber: 100) > 50
]

{ #category : #'private-random operations' }
GPConfiguration >> randomElementOf: aCollection [

	^ aCollection at: (random randomNumber: aCollection size)
]

{ #category : #'private-random operations' }
GPConfiguration >> randomInt: anInt [

	^ random randomNumber: anInt
]

{ #category : #accessing }
GPConfiguration >> rulesWeights [

	^ rulesWeights
]

{ #category : #accesing }
GPConfiguration >> rulesWeightsOf: keys [

	 ^ rulesWeights associations select: [ :assoc | keys includes: assoc key ] thenCollect: [ :assoc | assoc value ]
]
