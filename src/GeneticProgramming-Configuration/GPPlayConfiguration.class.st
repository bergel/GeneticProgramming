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
	| rootNode |
	rootNode := self newFunction.
	^ rootNode
]

{ #category : #operations }
GPPlayConfiguration >> distanceFromSolutionOf: individual [
	| p t |
	p := GPPlay new.
	p assertionGP: [ :obj | individual evaluateWith: { 'obj' -> obj } asDictionary ].
	t := GPPlayTest buildSuite run.
	individual fitness: t runCount - t passedCount.
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
		addRule: #E redirectingTo: #Variable;
		addRule: #E redirectingTo: #E2;
		addRule: #E2 ofClass: RBMessageNode withSequence: #(#Variable #Message);
		addSelectorRule: #And withValues: #(#and:);
		addSelectorRule: #Satisfy withValues: #(#allSatisfy: #noneSatisfy:);
		addSelectorRule: #Message withValues: #(#isNil #isCollection #isNumber #isByteString #isFloat #isNotNil #isLiteral);
		addRule: #Block ofClass: RBBlockNode withSequence: #(#E);
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #('obj').
	"grammar configuration: self."
	^ grammar
]

{ #category : #operations }
GPPlayConfiguration >> mutate: individual [
	| found i source children nodeToMutate |
	children := GPRandom instance shuffleElementsOf: (individual withAllChildren select: #isLeaf).
	found := false.
	i := 0.
	[ found or: [ i > 20 ] ] whileFalse: [ | indivIds sourceIds sceChildren |
		source := self newTerminal.
		indivIds := children collect: #id.
		sceChildren := source withAllChildren select: #isLeaf.
		sourceIds := sceChildren collect: #id.
		(indivIds includesAny: sourceIds) ifTrue: [ 
			nodeToMutate := children at: (indivIds indexOfAnyOf: sourceIds).
			source := sceChildren at: (sourceIds indexOf: nodeToMutate id).
			found := true ].
		i := i + 1 ].
	nodeToMutate ifNotNil: [ 
		nodeToMutate evaluationBlock: source evaluationBlock.
		nodeToMutate printBlock: source printBlock.
		nodeToMutate type: source type.
		nodeToMutate nodeValue: source nodeValue ]
]

{ #category : #hooks }
GPPlayConfiguration >> newFunction [ 
	| node found i |
	found := false.
	i := 0.
	[ found and: [ i > 10 ] ] whileFalse: [ 
		depth := GPRandom instance randomNumber: 5.
		grammar methodName: (GPRandom instance randomlySelect: #(#full #grow)). "method = #full ifTrue: [ self halt ]."
		node := grammar expandTree: #E withDepth: depth.
		found := node isNotNil.
		i := i + 1. ].
	node ifNil: [ self halt. ].
	node evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ].
	^ node
]

{ #category : #hooks }
GPPlayConfiguration >> newTerminal [
	^ self newFunction 
]

{ #category : #accessing }
GPPlayConfiguration >> populationSize [ 
	^ 50
]
