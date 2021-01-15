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
		addMessageRule: #AddOp withValues: #( #+ #-);
      addRule: #E redirectingTo: #T;
		addRule: #T ofClass: RBMessageNode  withSequence: #( #T #MultOp #F );
	 	addMessageRule: #MultOp withValues: #( #* #/);
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
	[ found or: [ i > 20 ] ] whileFalse: [ 
		source := self newTerminal.
		nodeToMutate := (children select: #isLeafNode) 
			detect: [ :child | child id == source id ] 
			ifNone: [ | msgs ids |
				msgs := source withAllChildren select: #isMessageNode.
				ids := msgs collect: #id.
				(children select: #isMessageNode) 
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
GPGrammarConfiguration >> newFunction [ 
	| node "isTerminal" |
	"isTerminal := false.
	[ isTerminal ] whileFalse: [  node := grammar expand. 
	isTerminal := node isLeafNode ]."
	node := grammar expand"GivenMethod: (GPRandom instance randomlySelect: #(#grow #full))".
	"ast := grammar generateASTFrom: node."
	node evaluationBlock: [ :n :ctx | (grammar generateASTFrom: n) evaluate ];
		printBlock: [ :n :ctx | (grammar generateASTFrom: n) formattedCode ].
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
	node := grammar expandFrom: symbol"GivenMethod: (GPRandom instance randomlySelect: #(#grow #full))".
	"ast := grammar generateASTFrom: node."
	node evaluationBlock: [ :n :ctx | | ast | 
		ast := (grammar generateASTFrom: n).
		[ ast evaluate ] on: MessageNotUnderstood do: [ ast ] ];
		printBlock: [ :n :ctx | | ast | 
		ast := (grammar generateASTFrom: n).
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
