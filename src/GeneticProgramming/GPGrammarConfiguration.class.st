Class {
	#name : #GPGrammarConfiguration,
	#superclass : #GPConfiguration,
	#instVars : [
		'grammar'
	],
	#category : #'GeneticProgramming-Core'
}

{ #category : #operations }
GPGrammarConfiguration >> createNewIndividual [	
	| rootNode |
	rootNode := self newFunction.
	^ rootNode
]

{ #category : #operations }
GPGrammarConfiguration >> distanceFromSolutionOf: individual [
	^ (individual evaluate - 234) abs
]

{ #category : #example }
GPGrammarConfiguration >> example [ 	
	| e |
	e := GPEngine new.
	GPRandom seed: 1342.
	e configuration: GPGrammarConfiguration new.
	e execute.
	^ e pickBestIndividual.
]

{ #category : #initialization }
GPGrammarConfiguration >> initialize [ 
	super initialize.
	grammar := self initializeGrammar.
]

{ #category : #initialization }
GPGrammarConfiguration >> initializeGrammar [
	grammar := GPContextFreeGrammar new.
	grammar 
      addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #T );
		addMessageRule: #AddOp withValues: #( #+ );
      addRule: #E redirectingTo: #T;
		addRule: #T ofClass: RBMessageNode  withSequence: #( #T #MultOp #F );
	 	addMessageRule: #MultOp withValues: #( #* );
	 	addRule: #T redirectingTo: #F;
	 	addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10).
	^ grammar
]

{ #category : #operations }
GPGrammarConfiguration >> mutate: individual [
	| nodeToMutate source |
	"nodeToMutate := self randomElementOf: (individual withAllChildren select: [ :n | n isLeafNode ])."
	source := self newTerminal.
	nodeToMutate := individual withAllChildren detect: [ :ch | ch isKindOf: source class ] 
		ifNone: [ | types found |
			found := false.
			types := (individual withAllChildren collect: #class) asSet.
			[ found ] whileFalse: [ source := self newTerminal.
				found := types includes: source class ].
			individual withAllChildren detect: [ :ch | ch isKindOf: source class ] ifNone: [ self halt ].
		].
	nodeToMutate evaluationBlock: source evaluationBlock.
	nodeToMutate printBlock: source printBlock.
	nodeToMutate type: source type.
]

{ #category : #hooks }
GPGrammarConfiguration >> newFunction [ 
	| node "isTerminal" |
	"isTerminal := false.
	[ isTerminal ] whileFalse: [  node := grammar expand. 
	isTerminal := node isLeafNode ]."
	node := grammar expand"GivenMethod: (GPRandom instance randomlySelect: #(#grow #full))".
	"ast := grammar generateASTFrom: node."
	node evaluationBlock: [ :n :ctx | grammar generateASTFrom: n.
		n ast evaluate ];
		printBlock: [ :n :ctx | n ast formattedCode ].
	"node children do: [ :child | 
		child evaluationBlock: [ :ch :ctx | ast evaluate ];
		printBlock: [ :ch :ctx | ast formattedCode ] ].
	node evaluationBlock: [ :ch :ctx |  ast evaluate ].
	node printBlock: [ :ch :ctx | ast formattedCode ]."
	^ node
]

{ #category : #hooks }
GPGrammarConfiguration >> newTerminal [
	^ self newFunction 
]

{ #category : #accessing }
GPGrammarConfiguration >> populationSize [ 
	^ 20
]
