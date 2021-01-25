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
		addRule: #E redirectingTo: #Variable;
		addRule: #E redirectingTo: #E2;
		addRule: #E2 ofClass: RBMessageNode withSequence: #(#Variable #Message);
		
		addSelectorRule: #And withValues: #(#and:);
		addSelectorRule: #Message withValues: #(#isNil #isCollection #isNumber #isByteString #isFloat #isNotNil);
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
	[ found or: [ i > 20 ] ] whileFalse: [ 
		source := self newTerminal.
		nodeToMutate := (children select: #isLeafNode) 
			detect: [ :child | child id == source id ] 
			ifNone: [ | msgs ids |
				msgs := source withAllChildren select: #isSelectorNode.
				ids := msgs collect: #id.
				(children select: #isSelectorNode) 
					detect: [ :ms | ids includes: ms id ]
					ifFound: [ :ms | source := msgs at: (ids indexOf: ms id).
						ms ]
					ifNone: [ nil ] ]. 
		found := nodeToMutate isNotNil.
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
		depth := GPRandom instance randomNumber: 10.
		method := GPRandom instance randomlySelect: #(#full #grow). "method = #full ifTrue: [ self halt ]."
		node := grammar expandTreeFrom: #E withDepth: depth.
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
	^ 20
]
