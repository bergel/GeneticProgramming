Class {
	#name : #GPPlayConfiguration,
	#superclass : #GPConfiguration,
	#instVars : [
		'grammar',
		'testClass'
	],
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #operations }
GPPlayConfiguration >> createNewIndividual [	
	^ self newFunction
]

{ #category : #'as yet unclassified' }
GPPlayConfiguration >> crossover: individual1 with: individual2 [
	 | copy ids childNodes childIds shuffleIds indexes |
	copy := individual1 deepCopy.
	ids := copy children collect: #id.
	childNodes := individual2 withAllChildren allButFirst.
	childIds := childNodes collect: #id.
	shuffleIds := random shuffleElementsOf: ids copy.
	shuffleIds 
		detect: [ :nodeId | 
			indexes := random shuffleElementsOf: (individual1 indexesOf: nodeId on: childIds).
			indexes notEmpty ]
		ifFound: [ :nodeId | copy children at: (ids indexOf: nodeId) put: (childNodes at: indexes first) deepCopy.
			^ copy ]
		ifNone: [ | c |
			copy children 
				detect: [ :child | 
					c := self crossover: child with: individual2.
					c notNil ] 
				ifFound: [ :child | 
					copy children at: (ids indexOf: child id) put: c.
					^ copy ]  ].
	^ nil
		
]

{ #category : #operations }
GPPlayConfiguration >> distanceFromSolutionOf: individual [
	| p t |
	p := GPPlay new.
	p assertionGP: [ :obj | individual evaluateWith: { 'obj' -> obj } asDictionary ].
	t := testClass buildSuite run.
	individual fitness: (GPFitnessFunction new
		fitnessValue: t failureCount + t errorCount;
		objective: [:fitness | fitness fitnessValue == 0 ]).
	^ individual fitness
]

{ #category : #example }
GPPlayConfiguration >> example [ 	
	| e |
	e := GPEngine new.
	GPRandom seed: 1.
	e configuration: self class new.
	e execute.
	^ e pickBestIndividual.
]

{ #category : #initialization }
GPPlayConfiguration >> initialize [ 
	super initialize.
	grammar := self initializeGrammar.
	testClass := GPPlayTest
]

{ #category : #initialization }
GPPlayConfiguration >> initializeGrammar [
	"Should find something like:
		obj isNotNil and: [ obj isCollection ]
		
	Messages the algorithm can use:
		isNil
		or:
		and:
		isCollection
		isNumber
		isByteString
		isFloat
	"
	grammar := GPContextFreeGrammar new.
	grammar 
		addRule: #E ofClass: RBMessageNode withSequence: #(#E #And #Block);
		addRule: #E ofClass: RBMessageNode withSequence: #(#Variable #Satisfy #Message);
		"addRule: #E redirectingTo: #Variable;"
		addRule: #E ofClass: RBMessageNode withSequence: #(#Variable #Message);
		addSelectorRule: #And withValues: #(#and:);
		addSelectorRule: #Satisfy withValues: #(#allSatisfy: #noneSatisfy:);
		addSelectorRule: #Message withValues: #(#isNil #isCollection #isNumber #isString #isFloat #notNil #notEmpty);
		addRule: #Block ofClass: RBBlockNode withSequence: #(#E);
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #('obj').
	"grammar configuration: self."
	^ grammar
]

{ #category : #operations }
GPPlayConfiguration >> mutate: individual [
	| source children nodeToMutate indivIds sourceIds sceChildren |
	children := random shuffleElementsOf: (individual withAllChildren allButFirst "select: #isLeaf").
	source := self newTerminal.
	indivIds := children collect: #id.
	sceChildren := source withAllChildren "select: #isLeaf".
	sourceIds := sceChildren collect: #id.
	(indivIds includesAny: sourceIds) ifFalse: [ ^ self ].
	nodeToMutate := children at: (indivIds indexOfAnyOf: sourceIds).
	source := sceChildren at: (sourceIds indexOf: nodeToMutate id).
	nodeToMutate evaluationBlock: source evaluationBlock.
	nodeToMutate printBlock: source printBlock.
	nodeToMutate type: source type.
	nodeToMutate children: source children.
	nodeToMutate nodeValue: source nodeValue
]

{ #category : #hooks }
GPPlayConfiguration >> newFunction [ 
	| node found i |
	found := false.
	i := 0.
	[ found or: [ i > 30 ] ] whileFalse: [ 
		depth := random randomNumber: 10.
		grammar methodName: (random randomlySelect: #(#full #grow)).
		node := grammar expandTree: #E withDepth: depth.
		found := node isNotNil.
		i := i + 1. ].
	self assert: node notNil.
	node evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ].
	^ node
]

{ #category : #hooks }
GPPlayConfiguration >> newTerminal [
	^ self newFunction 
]

{ #category : #hooks }
GPPlayConfiguration >> numberOfGenerations [
	^ 25
]

{ #category : #accessing }
GPPlayConfiguration >> populationSize [ 
	^ 100
]
