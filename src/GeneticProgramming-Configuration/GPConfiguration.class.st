Class {
	#name : #GPConfiguration,
	#superclass : #Object,
	#instVars : [
		'random',
		'method',
		'ruleWeights',
		'optionWeights',
		'depth',
		'depthModified'
	],
	#category : #'GeneticProgramming-Configuration-Core'
}

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
GPConfiguration >> createNewIndividualRoot: rootNode depth: nDepth [
	nDepth = 1 ifTrue: [ 
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
				self createNewIndividualRoot: f depth: nDepth - 1 ]
			ifFalse: [ rootNode addChild: self newTerminal ] ]
]

{ #category : #accessing }
GPConfiguration >> depth [
	^ depth ifNil: [ random randomNumber: 7 ] ifNotNil: [ depth ]
]

{ #category : #accessing }
GPConfiguration >> depth: anInteger [
	self assert: anInteger isInteger.
	depth := anInteger.
	depthModified := true
]

{ #category : #operations }
GPConfiguration >> distanceFromSolutionOf: individual [
	"This method has to return a number that describes how close the individual is to the solution.
	If this returns 0, then the individual is a perfect match
	"
	self subclassResponsibility 
]

{ #category : #adding }
GPConfiguration >> forRule: symbol putWeight: number [

	 ruleWeights at: symbol put: number
]

{ #category : #adding }
GPConfiguration >> forRule: symbol putWeights: numbers [

	 optionWeights at: symbol put: numbers
]

{ #category : #initialization }
GPConfiguration >> initialize [
	super initialize.
	random := GPRandom instance.
	ruleWeights := Dictionary new.
	optionWeights := Dictionary new.
	method := #grow.
	depthModified := false
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
	nodeToMutate nodeValue: source nodeValue.
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

	^ optionWeights at: symbol ifAbsent: [ #(1) ]
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

{ #category : #'as yet unclassified' }
GPConfiguration >> selectOption: options given: weights [
	| sum rndIndex |
	sum := weights sum.
	rndIndex := random randomNumber: sum.
	weights doWithIndex: [ :weight :index | 
		rndIndex <= weight ifTrue: [ ^ options at: index ].
		rndIndex := rndIndex - weight
	].
	^ nil
]

{ #category : #initialization }
GPConfiguration >> selectRuleKey: options [
	^ (ruleWeights keys includesAll: options) 
		ifTrue: [ self selectOption: options given: (options collect: [:opt | ruleWeights at: opt]) ]
		ifFalse: [ 
			self selectOption: options given: (options collect: [:opt | ruleWeights at: opt ifAbsent: [ 1 ] ] ) ]
]

{ #category : #'as yet unclassified' }
GPConfiguration >> selectValue: options forRule: symbol [
	options ifEmpty: [ ^ nil ].
	^ optionWeights at: symbol 
		ifPresent: [ :weights | | wgtSize optSize |
			wgtSize := weights size.
			optSize := options size.
			wgtSize == optSize 
				ifTrue: [ self selectOption: options given: weights ] 
				ifFalse: [ wgtSize < optSize
					ifTrue: [ | ws |
						ws := weights asArray, ((1 to: optSize - wgtSize) collect: [ :n | 1 ]).
						self selectOption: options given: ws ] 
					ifFalse: [ self selectOption: options given: (weights copyFrom: 1 to: optSize) ] ] ]
		ifAbsent: [ GPRandom instance randomlySelect: options ]
]

{ #category : #'as yet unclassified' }
GPConfiguration >> shuffle: options forRule: symbol [
	^ optionWeights at: symbol 
		ifPresent: [ :weights | | wgtSize optSize |
			wgtSize := weights size.
			optSize := options size.
			wgtSize == optSize 
				ifTrue: [ self sort: options given: weights ] 
				ifFalse: [ wgtSize < optSize
					ifTrue: [ | ws |
						ws := weights asArray, ((1 to: optSize - wgtSize) collect: [ :n | 1 ]).
						self sort: options given: ws ] 
					ifFalse: [ self sort: options given: (weights copyFrom: 1 to: optSize) ] ] ]
		ifAbsent: [ GPRandom instance shuffleElementsOf: options ]
]

{ #category : #'as yet unclassified' }
GPConfiguration >> sort: options given: weights [
	| assocs |
	assocs := weights collectWithIndex: [ :w :i | i -> w ].
	assocs := assocs sort: [:a1 :a2 | a1 value < a2 value ].
	^ assocs collect: [ :assoc | options at: assoc key ]
]
