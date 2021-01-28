Class {
	#name : #GPGrammarConfiguration,
	#superclass : #GPConfiguration,
	#instVars : [
		'grammar'
	],
	#category : #'GeneticProgramming-Configuration-Grammar'
}

{ #category : #operations }
GPGrammarConfiguration >> createNewIndividual [	
	| rootNode |
	rootNode := self newFunction.
	^ rootNode
]

{ #category : #operations }
GPGrammarConfiguration >> distanceFromSolutionOf: individual [
	^ [(individual evaluate - 234) abs] on: MessageNotUnderstood do: [ 234 ]
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

{ #category : #accessing }
GPGrammarConfiguration >> grammar [ 
	^ grammar
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
		addSelectorRule: #AddOp withValues: #( #+ #-);
      addRule: #E redirectingTo: #T;
		addRule: #T ofClass: RBMessageNode  withSequence: #( #T #MultOp #F );
	 	addSelectorRule: #MultOp withValues: #( #* #/);
	 	addRule: #T redirectingTo: #F;
	 	addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10).
	^ grammar
]

{ #category : #operations }
GPGrammarConfiguration >> mutate: individual [
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
GPGrammarConfiguration >> newFunction [ 
	| node "isTerminal" |
	"isTerminal := false.
	[ isTerminal ] whileFalse: [  node := grammar expand. 
	isTerminal := node isLeafNode ]."
	node := grammar expand"GivenMethod: (GPRandom instance randomlySelect: #(#grow #full))".
	"ast := grammar generateASTFrom: node."
	node evaluationBlock: [ :n :ctx | [n ast evaluate] on: MessageNotUnderstood do: [ n ast ] ];
		printBlock: [ :n :ctx | [n ast formattedCode ] on: MessageNotUnderstood do: [ n ast ] ].
	"node children do: [ :child | 
		child evaluationBlock: [ :ch :ctx | ast evaluate ];
		printBlock: [ :ch :ctx | ast formattedCode ] ].
	node evaluationBlock: [ :ch :ctx |  ast evaluate ].
	node printBlock: [ :ch :ctx | ast formattedCode ]."
	^ node
]

{ #category : #hooks }
GPGrammarConfiguration >> newFunction: symbol [
	| node "isTerminal" |
	"isTerminal := false.
	[ isTerminal ] whileFalse: [  node := grammar expand. 
	isTerminal := node isLeafNode ]."
	node := grammar expandTree: symbol"GivenMethod: (GPRandom instance randomlySelect: #(#grow #full))".
	"ast := grammar generateASTFrom: node."
	node evaluationBlock: [ :n :ctx | | ast | 
		ast := n ast.
		[ ast evaluate ] on: MessageNotUnderstood do: [ ast ] ];
		printBlock: [ :n :ctx | | ast | 
		ast := n ast.
		[ ast formattedCode ] on: MessageNotUnderstood do: [ ast printString ] ].
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
