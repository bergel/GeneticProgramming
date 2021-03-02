Class {
	#name : #GPPlayConfiguration,
	#superclass : #GPConfiguration,
	#instVars : [
		'grammar'
	],
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #operations }
GPPlayConfiguration >> createNewIndividual [	
	^ self newFunction
]

{ #category : #operations }
GPPlayConfiguration >> distanceFromSolutionOf: individual [
	| p t |
	p := GPPlay new.
	p assertionGP: [ :obj | individual evaluateWith: { 'obj' -> obj } asDictionary ].
	t := GPPlayTest buildSuite run.
	individual fitness: t runCount + t failureCount + t errorCount - t passedCount.
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
	children := GPRandom instance shuffleElementsOf: (individual withAllChildren allButFirst "select: #isLeaf").
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
		depth := GPRandom instance randomNumber: 10.
		grammar methodName: (GPRandom instance randomlySelect: #(#full #grow)).
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
