Class {
	#name : #GPGrammarConfiguration,
	#superclass : #GPConfiguration,
	#category : #'GeneticProgramming-Core'
}

{ #category : #operations }
GPGrammarConfiguration >> distanceFromSolutionOf: individual [
	^ (individual evaluate - 234) abs
]

{ #category : #hooks }
GPGrammarConfiguration >> newFunction [ 
	| grammar node ast |
	"GPRandom instance seed: 10."
	grammar := GPContextFreeGrammar new.
	grammar 
      addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #T );
		addMessageRule: #AddOp withValues: #( #+ );
      addRule: #E redirectingTo: #T;
		addRule: #T ofClass: RBMessageNode  withSequence: #( #T #MultOp #F );
	 	addMessageRule: #MultOp withValues: #( #* );
	 	addRule: #T redirectingTo: #F;
	 	addLeafRule: #F ofClass: RBLiteralNode withValues: ((1 to: 10)).
	node := grammar expandFrom: #E.
	ast := grammar generateASTFrom: node.
	node evaluationBlock: [ :ch :ctx | ast evaluate ].
	node printBlock: [ :ch :ctx | ast formattedCode ].
	^ node
]

{ #category : #hooks }
GPGrammarConfiguration >> newTerminal [
	^ self newFunction 
]

{ #category : #accessing }
GPGrammarConfiguration >> populationSize [ 
	^ 40
]
